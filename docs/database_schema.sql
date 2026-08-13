


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE TYPE "public"."transaction_type" AS ENUM (
    'IN',
    'OUT'
);


ALTER TYPE "public"."transaction_type" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."check_location_empty_before_soft_delete"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  active_count INT;
BEGIN
  -- Chỉ kích hoạt kiểm tra khi user cố gắng đổi trạng thái deleted từ false -> true
  IF NEW.deleted = true AND OLD.deleted = false THEN
    
    -- Đếm số lượng linh kiện còn active trong ngăn tủ này
    SELECT COUNT(*) INTO active_count 
    FROM components 
    WHERE location_id = OLD.id AND deleted = false;

    -- Nếu còn linh kiện, ném lỗi chặn lệnh UPDATE lại
    IF active_count > 0 THEN
      RAISE EXCEPTION 'LOCATION_NOT_EMPTY: Không thể ẩn ngăn tủ "%" vì vẫn còn % linh kiện bên trong.', OLD.name, active_count;
    END IF;
    
  END IF;

  -- Nếu mọi thứ hợp lệ, cho phép lưu record (NEW)
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."check_location_empty_before_soft_delete"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."component_insert_trigger_function"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$BEGIN
  NEW.created_at = NOW();
  NEW.updated_at = NOW();

  RETURN NEW;
END;$$;


ALTER FUNCTION "public"."component_insert_trigger_function"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."component_update_trigger_function"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$DECLARE
    is_bypassed TEXT;
BEGIN
    IF NEW.deleted IS TRUE AND COALESCE(OLD.deleted, FALSE) IS FALSE THEN
        IF OLD.quantity > 0 THEN
            RAISE EXCEPTION 'Không được xoá linh kiện khi số lượng khác 0';
        END IF;
    END IF;
    
    -- Đọc giá trị thẻ VIP (trả về NULL nếu không có)
    -- Tham số true ở cuối giúp không báo lỗi nếu biến này chưa được khởi tạo
    is_bypassed := current_setting('component_lab.bypass_quantity', true);

    -- 1. NẾU CÓ THẺ VIP -> CHO QUA LUÔN KHÔNG CẦN HỎI
    IF is_bypassed = 'true' THEN
        NEW.updated_at = NOW();
        RETURN NEW;
    END IF;

    -- 2. NẾU KHÔNG CÓ THẺ VIP -> KIỂM TRA NHƯ BÌNH THƯỜNG
    IF NEW.quantity IS DISTINCT FROM OLD.quantity THEN
        RAISE EXCEPTION 'Bảo mật: Không được phép cập nhật trực tiếp số lượng (quantity).';
    END IF;

    -- Cập nhật thời gian
    NEW.updated_at = NOW();
    RETURN NEW;
END;$$;


ALTER FUNCTION "public"."component_update_trigger_function"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_user_by_owner"("new_email" "text", "new_password" "text", "new_full_name" "text", "new_role_id" "text") RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
  caller_role TEXT;
  new_uid UUID;
BEGIN
  -- 1. Xác thực quyền Owner
  SELECT role_id INTO caller_role 
  FROM public.user_roles 
  WHERE user_id = auth.uid()
  LIMIT 1;

  IF caller_role IS NULL OR caller_role != 'owner' THEN
    RAISE EXCEPTION 'ACCESS_DENIED: Chỉ hệ thống Owner mới được phép cấp phát tài khoản mới.';
  END IF;

  -- 2. Validate Role & Email
  IF NOT EXISTS (SELECT 1 FROM public.roles WHERE id = new_role_id) THEN
    RAISE EXCEPTION 'INVALID_ROLE: Mã phân quyền "%" không tồn tại trong hệ thống.', new_role_id;
  END IF;

  IF EXISTS (SELECT 1 FROM auth.users WHERE email = lower(new_email)) THEN
    RAISE EXCEPTION 'EMAIL_EXISTS: Trùng lặp dữ liệu. Email "%" đã được đăng ký.', new_email;
  END IF;

  -- 3. Cấp phát UUID mới
  new_uid := gen_random_uuid();

  -- 4. Ghi dữ liệu vào auth.users (Đã điền đầy đủ các chuỗi rỗng cho Token)
  INSERT INTO auth.users (
    instance_id,
    id, 
    aud,
    role,
    email, 
    encrypted_password,
    email_confirmed_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at, 
    updated_at,
    -- --- CÁC CỘT VÁ LỖI ÉP KIỂU GOLANG ---
    confirmation_token,       -- Sửa lỗi cột index 3 bị NULL
    recovery_token,           -- Phòng ngừa lỗi tương tự cho tính năng Quên mật khẩu
    email_change,
    email_change_token_new,   -- Phòng ngừa lỗi tương tự cho tính năng Đổi Email
    email_change_token_current,
    phone_change_token
  ) VALUES (
    '00000000-0000-0000-0000-000000000000', 
    new_uid,
    'authenticated',
    'authenticated',
    lower(new_email),
    extensions.crypt(new_password, extensions.gen_salt('bf')), 
    now(), 
    '{"provider":"email","providers":["email"]}'::jsonb,
    jsonb_build_object('full_name', new_full_name),
    now(),
    now(),
    -- --- GIÁ TRỊ VÁ LỖI: Điền chuỗi rỗng '' thay vì để NULL ---
    '', -- confirmation_token
    '', -- recovery_token
    '', -- email_change
    '', -- email_change_token_new
    '', -- email_change_token_current
    ''  -- phone_change_token
  );

  -- 5. Ghi dữ liệu vào auth.identities
  INSERT INTO auth.identities (
    id,
    user_id,
    provider_id,
    identity_data,
    provider,
    last_sign_in_at,
    created_at,
    updated_at
  ) VALUES (
    gen_random_uuid(),
    new_uid,
    new_uid::text,
    jsonb_build_object('sub', new_uid, 'email', lower(new_email), 'email_verified', true),
    'email',
    now(),
    now(),
    now()
  );

  -- 6. Ghi phân quyền hệ thống vào user_roles
  INSERT INTO public.user_roles (user_id, role_id)
  VALUES (new_uid, new_role_id)
  ON CONFLICT (user_id) 
  DO UPDATE SET role_id = new_role_id;

  RETURN new_uid;
END;
$$;


ALTER FUNCTION "public"."create_user_by_owner"("new_email" "text", "new_password" "text", "new_full_name" "text", "new_role_id" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."delete_user_by_owner"("target_uid" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$DECLARE
  caller_role text;
BEGIN
  -- 1. Kiểm tra vai trò của người đang gọi hàm (dựa vào auth.uid() bóc xuất từ JWT Token)
  SELECT role_id INTO caller_role 
  FROM public.user_roles 
  WHERE user_id = auth.uid();

  -- 2. Chốt chặn bảo mật (Authorization Guard)
  IF caller_role IS NULL OR caller_role != 'owner' THEN
    RAISE EXCEPTION 'ACCESS_DENIED: Bạn không có đặc quyền Owner để xoá người dùng hệ thống.';
  END IF;

  IF auth.uid() = target_uid THEN
    RAISE EXCEPTION 'DELETE_SELF_ACCOUNT: Bạn đang tự tay xóa tài khoản của mình';
  END IF;
  -- 3. Xoá người dùng khỏi bảng lõi auth.users
  -- Lưu ý: Nếu bạn có cài đặt Foreign Key với cờ ON DELETE CASCADE ở các bảng khác (như user_roles), 
  -- dữ liệu liên quan sẽ tự động bốc hơi theo.
  DELETE FROM auth.users WHERE id = target_uid;
  
END;$$;


ALTER FUNCTION "public"."delete_user_by_owner"("target_uid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."export_components"("payload" "jsonb", "p_notes" "text" DEFAULT NULL::"text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$DECLARE
  item RECORD;
  v_transaction_id UUID;
  
  -- Khai báo 2 biến để hứng tổng
  v_total_components INT;
  v_total_amount INT;
BEGIN
  PERFORM set_config('component_lab.bypass_quantity', 'true', true);
  -- 1. [TÍNH TOÁN TRƯỚC]: Đếm số lượng loại linh kiện và tổng số lượng
  v_total_components := jsonb_array_length(payload);
  
  SELECT COALESCE(SUM((x->>'quantity')::INT), 0) 
  INTO v_total_amount 
  FROM jsonb_array_elements(payload) AS x;

  -- 2. TẠO HEADER GIAO DỊCH XUẤT (Chèn luôn 2 cột total vào)
  INSERT INTO transactions_header (
    user_id, type, notes, total_components, total_amount
  )
  VALUES (
    auth.uid(), 'OUT', p_notes, v_total_components, v_total_amount
  )
  RETURNING id INTO v_transaction_id;

  -- 3. Lặp qua để trừ Kho và chèn Details
  FOR item IN SELECT * FROM jsonb_to_recordset(payload) AS x(id UUID, quantity INT)
  LOOP
    -- Thực hiện trừ kho
    UPDATE components
    SET quantity = quantity - item.quantity
    WHERE id = item.id;

    -- Ghi chi tiết giao dịch
    INSERT INTO transactions_details (transaction_id, component_id, amount)
    VALUES (v_transaction_id, item.id, item.quantity);

  END LOOP;
END;$$;


ALTER FUNCTION "public"."export_components"("payload" "jsonb", "p_notes" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_all_users_directory"() RETURNS TABLE("id" "uuid", "email" character varying, "full_name" "text", "avatar_url" "text", "role" "text", "created_at" timestamp with time zone, "last_sign_in_at" timestamp with time zone)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  caller_role text;
BEGIN
  -- 1. [BẢO MẬT TẦNG 1] Lấy role của user đang thực thi hàm
  SELECT role_id INTO caller_role 
  FROM public.user_roles 
  WHERE user_id = auth.uid();

  -- 2. Kiểm tra điều kiện ngặt (Strict Check)
  IF caller_role IS NULL OR caller_role != 'owner' THEN
    RAISE EXCEPTION 'ACCESS_DENIED: Hàm này chỉ dành riêng cho Owner. UID gọi hàm: %', auth.uid();
  END IF;

  -- 3. [TRUY VẤN DỮ LIỆU] 
  RETURN QUERY
  SELECT 
    au.id,
    au.email::varchar,
    (au.raw_user_meta_data->>'full_name')::text AS full_name,
    (au.raw_user_meta_data->>'avatar_url')::text AS avatar_url,
    COALESCE(ur.role_id, 'manager')::text AS role,
    au.created_at,
    au.last_sign_in_at
  FROM auth.users au
  LEFT JOIN public.user_roles ur ON au.id = ur.user_id
  ORDER BY au.created_at DESC;
END;
$$;


ALTER FUNCTION "public"."get_all_users_directory"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_transaction_details"("p_transaction_id" "uuid") RETURNS TABLE("id" "uuid", "name" "text", "category_name" "text", "location_name" "text", "quantity" integer)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$BEGIN
    RETURN QUERY
    SELECT 
        td.component_id,
        -- Nếu linh kiện không tồn tại (bị xóa vật lý), trả về chuỗi rỗng
        COALESCE(c.name, 'Linh kiện đã bị xoá')::TEXT AS name,
        
        -- Nếu phân loại không tồn tại, trả về chuỗi rỗng
        COALESCE(cat.name, 'Phân loại đã bị xoá')::TEXT AS category_name,
        
        -- Nếu vị trí không tồn tại, trả về chuỗi rỗng
        COALESCE(loc.name, 'Ngăn tủ đã bị xoá')::TEXT AS location_name,
        
        td.amount as quantity
    FROM public.transactions_details td
    -- Dùng LEFT JOIN để giữ lại giao dịch ngay cả khi linh kiện đã bị xóa mất
    LEFT JOIN public.components c ON td.component_id = c.id
    LEFT JOIN public.categories cat ON c.category_id = cat.id
    LEFT JOIN public.locations loc ON c.location_id = loc.id
    -- Lọc đúng giao dịch mà người dùng truyền vào
    WHERE td.transaction_id = p_transaction_id;
END;$$;


ALTER FUNCTION "public"."get_transaction_details"("p_transaction_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_transaction_history"() RETURNS TABLE("id" "uuid", "user_id" "uuid", "type" "text", "notes" "text", "total_components" integer, "total_amount" integer, "created_at" timestamp with time zone, "user_name" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        th.id,
        th.user_id,
        th.type::TEXT,     -- Ép kiểu từ enum transaction_type sang TEXT
        th.notes,
        th.total_components,
        th.total_amount,
        th.created_at,
        
        -- LOGIC XỬ LÝ TÊN NGƯỜI DÙNG
        CASE 
            WHEN au.id IS NULL THEN 'Người dùng đã bị xoá'
            ELSE COALESCE((au.raw_user_meta_data->>'full_name')::TEXT, 'Người dùng không tên')
        END AS user_name
        
    FROM public.transactions_header th
    -- Dùng LEFT JOIN: Nếu không tìm thấy id trong auth.users, nó sẽ trả về NULL thay vì báo lỗi
    LEFT JOIN auth.users au ON th.user_id = au.id
    
    -- Sắp xếp mới nhất lên đầu
    ORDER BY th.created_at DESC;
END;
$$;


ALTER FUNCTION "public"."get_transaction_history"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_user_role"() RETURNS character varying
    LANGUAGE "sql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
  -- Giới hạn LIMIT 1 để đảm bảo query chạy cực nhanh và không trả về mảng
  SELECT role_id FROM public.user_roles WHERE user_id = auth.uid() LIMIT 1;
$$;


ALTER FUNCTION "public"."get_user_role"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$BEGIN
  -- Gán mặc định role_id là 'manager' khi có user mới
  INSERT INTO user_roles (user_id, role_id)
  VALUES (NEW.id, 'manager')
  ON CONFLICT (user_id) DO NOTHING;
  
  RETURN NEW;
END;$$;


ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."import_components"("payload" "jsonb", "p_notes" "text" DEFAULT NULL::"text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$DECLARE
  item JSONB;
  v_comp_id UUID;
  v_transaction_id UUID;
  v_amount INT;
  
  -- Khai báo 2 biến để hứng tổng
  v_total_components INT;
  v_total_amount INT;
BEGIN
  PERFORM set_config('component_lab.bypass_quantity', 'true', true);
  -- 1. [TÍNH TOÁN TRƯỚC]: Đếm số lượng loại linh kiện và tổng số lượng
  v_total_components := jsonb_array_length(payload); -- Số lượng object trong mảng
  
  SELECT COALESCE(SUM((x->>'quantity')::INT), 0) 
  INTO v_total_amount 
  FROM jsonb_array_elements(payload) AS x;

  -- 2. TẠO HEADER GIAO DỊCH (Chèn luôn 2 cột total vào)
  INSERT INTO transactions_header (
    user_id, type, notes, total_components, total_amount
  )
  VALUES (
    auth.uid(), 'IN', p_notes, v_total_components, v_total_amount
  )
  RETURNING id INTO v_transaction_id; 

  -- 3. Lặp qua từng object để xử lý Kho và chèn Details
  FOR item IN SELECT * FROM jsonb_array_elements(payload)
  LOOP
    v_amount := (item->>'quantity')::INT;

    -- TH1: LINH KIỆN MỚI
    IF item->>'id' IS NULL OR item->>'id' = '' THEN
      INSERT INTO components (
        name, quantity, min_threshold, location_id, category_id, specs, image_url, added_via_ai, datasheet_url
      )
      VALUES (
        item->>'name', v_amount, COALESCE((item->>'minThreshold')::INT, 10), 
        (item->>'location_id')::UUID, item->>'category_id', item->'specs', 
        item->>'image_url', (item->>'added_via_ai')::boolean, item->>'datasheet_url'
      )
      RETURNING id INTO v_comp_id; 

    -- TH2: LINH KIỆN CŨ
    ELSE
      v_comp_id := (item->>'id')::UUID;
      UPDATE components
      SET quantity = quantity + v_amount
      WHERE id = v_comp_id;
    END IF;

    -- Ghi chi tiết
    INSERT INTO transactions_details (transaction_id, component_id, amount)
    VALUES (v_transaction_id, v_comp_id, v_amount);

  END LOOP;
END;$$;


ALTER FUNCTION "public"."import_components"("payload" "jsonb", "p_notes" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_modified_column"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$BEGIN
    NEW.updated_at = NOW();

    RETURN NEW;
END;$$;


ALTER FUNCTION "public"."update_modified_column"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_user_info_by_owner"("target_uid" "uuid", "new_full_name" "text", "new_role_id" "text") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$DECLARE
  caller_role text;
BEGIN
  -- 1. Xác thực người gọi hàm (Chỉ Owner mới được chạy)
  SELECT role_id INTO caller_role 
  FROM public.user_roles 
  WHERE user_id = auth.uid();

  IF caller_role IS NULL OR caller_role != 'owner' THEN
    RAISE EXCEPTION 'ACCESS_DENIED: Chỉ chủ sở hữu (owner) mới có quyền cập nhật thông tin người dùng.';
  END IF;

  -- 2. VALIDATE ĐỘNG: Kiểm tra xem new_role_id có tồn tại trong bảng `roles` hay không
  -- Dùng EXISTS cho tốc độ truy vấn cực nhanh thay vì đếm COUNT hay IN
  IF NOT EXISTS (SELECT 1 FROM public.roles WHERE id = new_role_id) THEN
    RAISE EXCEPTION 'INVALID_ROLE: Role ID "%" không tồn tại trong hệ thống từ điển.', new_role_id;
  END IF;

  -- 3. Cập nhật Tên trong bảng auth.users
  UPDATE auth.users 
  SET raw_user_meta_data = jsonb_set(
    COALESCE(raw_user_meta_data, '{}'::jsonb), 
    '{full_name}', 
    to_jsonb(new_full_name)
  )
  WHERE id = target_uid;

  -- 4. Cập nhật Role trong bảng public.user_roles
  INSERT INTO public.user_roles (user_id, role_id)
  VALUES (target_uid, new_role_id)
  ON CONFLICT (user_id) 
  DO UPDATE SET role_id = new_role_id;

END;$$;


ALTER FUNCTION "public"."update_user_info_by_owner"("target_uid" "uuid", "new_full_name" "text", "new_role_id" "text") OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."categories" (
    "id" character varying(50) NOT NULL,
    "name" character varying(255) NOT NULL,
    "description" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "image_url" "text"
);


ALTER TABLE "public"."categories" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."components" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "name" character varying(255) NOT NULL,
    "quantity" integer DEFAULT 0 NOT NULL,
    "min_threshold" integer DEFAULT 5 NOT NULL,
    "location_id" "uuid" NOT NULL,
    "specs" "jsonb" DEFAULT '{}'::"jsonb",
    "image_url" "text",
    "added_via_ai" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "category_id" character varying(50) NOT NULL,
    "deleted" boolean DEFAULT false NOT NULL,
    "datasheet_url" "text",
    CONSTRAINT "components_quantity_check" CHECK (("quantity" >= 0))
);


ALTER TABLE "public"."components" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."location_stats" AS
SELECT
    NULL::"uuid" AS "id",
    NULL::character varying(255) AS "name",
    NULL::"text" AS "description",
    NULL::bigint AS "total_items";


ALTER VIEW "public"."location_stats" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."locations" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "name" character varying(255) NOT NULL,
    "description" "text",
    "deleted" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."locations" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."roles" (
    "id" character varying(50) NOT NULL,
    "name" character varying(100) NOT NULL,
    "description" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "priority" smallint NOT NULL,
    CONSTRAINT "roles_priority_check" CHECK (("priority" > 0))
);


ALTER TABLE "public"."roles" OWNER TO "postgres";


ALTER TABLE "public"."roles" ALTER COLUMN "priority" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."roles_priority_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."transactions_details" (
    "transaction_id" "uuid" NOT NULL,
    "component_id" "uuid" NOT NULL,
    "amount" integer NOT NULL
);


ALTER TABLE "public"."transactions_details" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."transactions_header" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "type" "public"."transaction_type" NOT NULL,
    "notes" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "total_components" integer DEFAULT 1 NOT NULL,
    "total_amount" integer DEFAULT 1 NOT NULL,
    CONSTRAINT "transactions_header_total_amount_check" CHECK (("total_amount" > 0)),
    CONSTRAINT "transactions_header_total_components_check" CHECK (("total_components" > 0))
);


ALTER TABLE "public"."transactions_header" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_roles" (
    "user_id" "uuid" NOT NULL,
    "role_id" character varying(50) NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."user_roles" OWNER TO "postgres";


ALTER TABLE ONLY "public"."categories"
    ADD CONSTRAINT "categories_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."components"
    ADD CONSTRAINT "components_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."locations"
    ADD CONSTRAINT "locations_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."roles"
    ADD CONSTRAINT "roles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."transactions_details"
    ADD CONSTRAINT "transactions_details_pkey" PRIMARY KEY ("transaction_id", "component_id");



ALTER TABLE ONLY "public"."transactions_header"
    ADD CONSTRAINT "transactions_header_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_roles"
    ADD CONSTRAINT "user_roles_pkey" PRIMARY KEY ("user_id");



CREATE INDEX "idx_components_category_id" ON "public"."components" USING "btree" ("category_id");



CREATE INDEX "idx_components_specs" ON "public"."components" USING "gin" ("specs");



CREATE INDEX "transactions_details_index_0" ON "public"."transactions_details" USING "btree" ("transaction_id", "component_id");



CREATE OR REPLACE VIEW "public"."location_stats" WITH ("security_invoker"='true') AS
 SELECT "l"."id",
    "l"."name",
    "l"."description",
    "count"("c"."id") AS "total_items"
   FROM ("public"."locations" "l"
     LEFT JOIN "public"."components" "c" ON ((("l"."id" = "c"."location_id") AND ("c"."deleted" = false))))
  WHERE ("l"."deleted" = false)
  GROUP BY "l"."id", "l"."name";



CREATE OR REPLACE TRIGGER "prevent_location_soft_delete" BEFORE UPDATE ON "public"."locations" FOR EACH ROW EXECUTE FUNCTION "public"."check_location_empty_before_soft_delete"();



CREATE OR REPLACE TRIGGER "trigger_update_categories_modtime" BEFORE UPDATE ON "public"."categories" FOR EACH ROW EXECUTE FUNCTION "public"."update_modified_column"();



CREATE OR REPLACE TRIGGER "trigger_update_components" BEFORE UPDATE ON "public"."components" FOR EACH ROW EXECUTE FUNCTION "public"."component_update_trigger_function"();



ALTER TABLE ONLY "public"."components"
    ADD CONSTRAINT "components_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "public"."categories"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."components"
    ADD CONSTRAINT "components_location_id_fkey" FOREIGN KEY ("location_id") REFERENCES "public"."locations"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."transactions_details"
    ADD CONSTRAINT "transactions_details_component_id_fkey" FOREIGN KEY ("component_id") REFERENCES "public"."components"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."transactions_details"
    ADD CONSTRAINT "transactions_details_transaction_id_fkey" FOREIGN KEY ("transaction_id") REFERENCES "public"."transactions_header"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."transactions_header"
    ADD CONSTRAINT "transactions_header_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."user_roles"
    ADD CONSTRAINT "user_roles_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "public"."roles"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."user_roles"
    ADD CONSTRAINT "user_roles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



CREATE POLICY "Admin và Owner được quyền chỉnh sửa locations" ON "public"."locations" TO "authenticated" USING ((("public"."get_user_role"())::"text" = ANY ((ARRAY['admin'::character varying, 'owner'::character varying])::"text"[])));



CREATE POLICY "Allow auth users to READ transactions_details" ON "public"."transactions_details" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Allow auth users to READ transactions_header" ON "public"."transactions_header" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Cho phép User đã đăng nhập full quyền trên categories" ON "public"."categories" TO "authenticated" USING (true);



CREATE POLICY "Cho phép authenicated có quyền update" ON "public"."components" FOR UPDATE TO "authenticated" USING (true);



CREATE POLICY "Cho phép người dùng đăng nhập có quyền đọc" ON "public"."components" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Cho phép user đã đăng nhập được đọc trên locatio" ON "public"."locations" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Chỉ owner được chỉnh sửa user_roles" ON "public"."user_roles" TO "authenticated" USING ((("public"."get_user_role"())::"text" = 'owner'::"text"));



CREATE POLICY "Mọi người được đọc roles" ON "public"."roles" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "User tự xem role của mình" ON "public"."user_roles" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "user_id"));



ALTER TABLE "public"."categories" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."components" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."locations" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."roles" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."transactions_details" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."transactions_header" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_roles" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";






















































































































































GRANT ALL ON FUNCTION "public"."check_location_empty_before_soft_delete"() TO "anon";
GRANT ALL ON FUNCTION "public"."check_location_empty_before_soft_delete"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_location_empty_before_soft_delete"() TO "service_role";



GRANT ALL ON FUNCTION "public"."component_insert_trigger_function"() TO "anon";
GRANT ALL ON FUNCTION "public"."component_insert_trigger_function"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."component_insert_trigger_function"() TO "service_role";



GRANT ALL ON FUNCTION "public"."component_update_trigger_function"() TO "anon";
GRANT ALL ON FUNCTION "public"."component_update_trigger_function"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."component_update_trigger_function"() TO "service_role";



GRANT ALL ON FUNCTION "public"."create_user_by_owner"("new_email" "text", "new_password" "text", "new_full_name" "text", "new_role_id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."create_user_by_owner"("new_email" "text", "new_password" "text", "new_full_name" "text", "new_role_id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_user_by_owner"("new_email" "text", "new_password" "text", "new_full_name" "text", "new_role_id" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."delete_user_by_owner"("target_uid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."delete_user_by_owner"("target_uid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."delete_user_by_owner"("target_uid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."export_components"("payload" "jsonb", "p_notes" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."export_components"("payload" "jsonb", "p_notes" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."export_components"("payload" "jsonb", "p_notes" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_all_users_directory"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_all_users_directory"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_all_users_directory"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_transaction_details"("p_transaction_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_transaction_details"("p_transaction_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_transaction_details"("p_transaction_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_transaction_history"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_transaction_history"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_transaction_history"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_user_role"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_user_role"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_user_role"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";



GRANT ALL ON FUNCTION "public"."import_components"("payload" "jsonb", "p_notes" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."import_components"("payload" "jsonb", "p_notes" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."import_components"("payload" "jsonb", "p_notes" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_modified_column"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_modified_column"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_modified_column"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_user_info_by_owner"("target_uid" "uuid", "new_full_name" "text", "new_role_id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."update_user_info_by_owner"("target_uid" "uuid", "new_full_name" "text", "new_role_id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_user_info_by_owner"("target_uid" "uuid", "new_full_name" "text", "new_role_id" "text") TO "service_role";


















GRANT ALL ON TABLE "public"."categories" TO "anon";
GRANT ALL ON TABLE "public"."categories" TO "authenticated";
GRANT ALL ON TABLE "public"."categories" TO "service_role";



GRANT ALL ON TABLE "public"."components" TO "anon";
GRANT ALL ON TABLE "public"."components" TO "authenticated";
GRANT ALL ON TABLE "public"."components" TO "service_role";



GRANT ALL ON TABLE "public"."location_stats" TO "anon";
GRANT ALL ON TABLE "public"."location_stats" TO "authenticated";
GRANT ALL ON TABLE "public"."location_stats" TO "service_role";



GRANT ALL ON TABLE "public"."locations" TO "anon";
GRANT ALL ON TABLE "public"."locations" TO "authenticated";
GRANT ALL ON TABLE "public"."locations" TO "service_role";



GRANT ALL ON TABLE "public"."roles" TO "anon";
GRANT ALL ON TABLE "public"."roles" TO "authenticated";
GRANT ALL ON TABLE "public"."roles" TO "service_role";



GRANT ALL ON SEQUENCE "public"."roles_priority_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."roles_priority_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."roles_priority_seq" TO "service_role";



GRANT ALL ON TABLE "public"."transactions_details" TO "anon";
GRANT ALL ON TABLE "public"."transactions_details" TO "authenticated";
GRANT ALL ON TABLE "public"."transactions_details" TO "service_role";



GRANT ALL ON TABLE "public"."transactions_header" TO "anon";
GRANT ALL ON TABLE "public"."transactions_header" TO "authenticated";
GRANT ALL ON TABLE "public"."transactions_header" TO "service_role";



GRANT ALL ON TABLE "public"."user_roles" TO "anon";
GRANT ALL ON TABLE "public"."user_roles" TO "authenticated";
GRANT ALL ON TABLE "public"."user_roles" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";































