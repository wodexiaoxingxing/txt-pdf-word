-- 备 注：
---是正确的身份证号 返回1 错误返回0
--          身份证号只有15或18位
--          如果是15位身份证 则只验证日期和是否数字格式
--          18位身份证 验证日期 校验位   
/*
身份证校验码的计算方法
 
1、将前面的身份证号码17位数分别乘以不同的系数。第i位对应的数为[2^(18-i)]mod11。从第一位到第十七位的系数分别为：7 9 10 5 8 4 2 1 6 3 7 9 10 5 8 4 2 ； 

2、将这17位数字和系数相乘的结果相加； 

3、用加出来和除以11，看余数是多少？； 

4、余数只可能有0 1 2 3 4 5 6 7 8 9 10这11个数字。其分别对应的最后一位身份证的号码为1 0 X 9 8 7 6 5 4 3 2； 

*/
--SQLServer ISNUMERIC函数 (当输入表达式的计算结果为有效的 numeric 数据类型时，ISNUMERIC 返回 1；否则返回 0)
--IsDate ( 函数可返一个布尔值，指示经计算的表达式是否可被转换为日期。如果表达式是日期，或可被转换为日期，则返回 True 。否则，返回 False )
-- =============================================
IF  EXISTS (SELECT * FROM sys.objects
WHERE object_id = OBJECT_ID(N'dbo.fun_IsValidID')
 AND type in ('IF', 'FN', 'TF'))
DROP FUNCTION dbo.fun_IsValidID
GO

CREATE FUNCTION dbo.fun_IsValidID(@ID Varchar(18))
 -- Add the parameters for the stored procedure here
 RETURNS BIT
AS
BEGIN
  DECLARE
   @ValidFactors VARCHAR(17),
   @ValidCodes VARCHAR(11),
          @I TINYINT,
          @iTemp INT

  --位数不满足则为非法ID

  IF Len(@ID) <> 15 AND Len(@ID) <> 18
 RETURN(0);

  --如果是15位身份证 则只验证日期和是否数字格式
  IF LEN(@ID)=15 
    IF ISDATE('19'+SUBSTRING(@ID,7,6))=0 OR ISNUMERIC(@ID)=0
      RETURN(0);
    ELSE
      RETURN(1);

  /*18位身份证 验证日期 校验位 */

    --验证日期和前17位是否数字格式
  IF ISDATE(SUBSTRING(@ID,7,8))=0 OR ISNUMERIC(SUBSTRING(@ID,1,17))=0
 RETURN(0);

 --验证校验位开始
  SELECT 
   @ValidFactors='79A584216379A5842',
   @ValidCodes='10X98765432',
      @I=1,@iTemp=0

  WHILE @i<18
  BEGIN
 SELECT
   @iTemp=@iTemp+CAST(SUBSTRING(@ID,@i,1) AS INT)*(CASE SUBSTRING(@validFactors,@i,1) WHEN 'A' THEN 10 ELSE SUBSTRING(@ValidFactors,@i,1) END)
   ,@i=@i+1
  END
  IF SUBSTRING(@ValidCodes,@iTemp%11+1,1)=RIGHT(@ID,1)
    RETURN(1);
  ELSE
    RETURN(0);
 
  RETURN NULL;
END