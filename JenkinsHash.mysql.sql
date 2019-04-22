-- 安全处理溢出加法
DROP FUNCTION safe_add;
CREATE FUNCTION safe_add ( a BIGINT UNSIGNED, b BIGINT UNSIGNED ) RETURNS BIGINT UNSIGNED BEGIN
IF
	( 18446744073709551615 - b >= a ) THEN
	RETURN ( a + b );
ELSE RETURN ( a - ( 18446744073709551615 - b ) - 1 );
END IF;
END;

-- 安全处理溢出减法
DROP FUNCTION safe_sub;
CREATE FUNCTION safe_sub ( a BIGINT UNSIGNED, b BIGINT UNSIGNED ) RETURNS BIGINT UNSIGNED BEGIN
	IF
		( a >= b ) THEN
			RETURN ( a - b );
		ELSE RETURN ( 18446744073709551615 - ( b - a ) + 1 );
	END IF;
END;

-- 64位无符号整数 转 BASE32 Jenkins Hash 字符串
DROP FUNCTION jtoh;
CREATE FUNCTION jtoh ( j BIGINT UNSIGNED ) RETURNS VARCHAR ( 20 ) BEGIN
	DECLARE
		r BIGINT UNSIGNED;
	SET r = j;
	SET r = safe_add ( ~ r, r << 21 );
	SET r = r ^ ( r >> 24 );
	SET r = safe_add ( safe_add ( r, r << 3 ), r << 8 );
	SET r = r ^ ( r >> 14 );
	SET r = safe_add ( safe_add ( r, r << 2 ), r << 4 );
	SET r = r ^ ( r >> 28 );
	SET r = safe_add ( r, r << 31 );
	RETURN ( lower( conv( r, 10, 32 ) ) );
END;

-- BASE32 Jenkins Hash 字符串 转 64位无符号整数
DROP FUNCTION htoj;
CREATE FUNCTION htoj ( h VARCHAR ( 20 ) ) RETURNS BIGINT UNSIGNED BEGIN
	DECLARE
		r BIGINT UNSIGNED;
	DECLARE
		t BIGINT UNSIGNED;
	SET r = conv( h, 32, 10 );
	SET t = safe_sub ( r, r << 31 );
	SET r = safe_sub ( r, t << 31 );
	SET t = r ^ ( r >> 28 );
	SET r = r ^ ( t >> 28 );
	SET r = r / 21;
	SET t = r ^ ( r >> 14 );
	SET t = r ^ ( t >> 14 );
	SET t = r ^ ( t >> 14 );
	SET r = r ^ ( t >> 14 );
	SET r = r / 265;
	SET t = r ^ ( r >> 24 );
	SET r = r ^ ( t >> 24 );
	SET t = ~ r;
	SET t = ~ safe_sub ( r, t << 21 );
	SET t = ~ safe_sub ( r, t << 21 );
	SET r = ~ safe_sub ( r, t << 21 );
	RETURN ( r );
END;
	

-- 测试
SELECT
	jtoh ( 1 ),
htoj ( jtoh ( 1 ) );


-- 测试用例
-- SELECT
-- 	id,
-- 	hash_id,
-- 	jtoh ( id ),
-- 	htoj ( hash_id ) 
-- FROM
-- 	hash_id 
-- WHERE
-- 	hash_id <> jtoh ( id ) 
-- 	OR id <> htoj ( hash_id );