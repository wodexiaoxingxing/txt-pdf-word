-- �� ע��
---����ȷ�����֤�� ����1 ���󷵻�0
--          ���֤��ֻ��15��18λ
--          �����15λ���֤ ��ֻ��֤���ں��Ƿ����ָ�ʽ
--          18λ���֤ ��֤���� У��λ   
/*
���֤У����ļ��㷽��
 
1����ǰ������֤����17λ���ֱ���Բ�ͬ��ϵ������iλ��Ӧ����Ϊ[2^(18-i)]mod11���ӵ�һλ����ʮ��λ��ϵ���ֱ�Ϊ��7 9 10 5 8 4 2 1 6 3 7 9 10 5 8 4 2 �� 

2������17λ���ֺ�ϵ����˵Ľ����ӣ� 

3���üӳ����ͳ���11���������Ƕ��٣��� 

4������ֻ������0 1 2 3 4 5 6 7 8 9 10��11�����֡���ֱ��Ӧ�����һλ���֤�ĺ���Ϊ1 0 X 9 8 7 6 5 4 3 2�� 

*/
--SQLServer ISNUMERIC���� (��������ʽ�ļ�����Ϊ��Ч�� numeric ��������ʱ��ISNUMERIC ���� 1�����򷵻� 0)
--IsDate ( �����ɷ�һ������ֵ��ָʾ������ı��ʽ�Ƿ�ɱ�ת��Ϊ���ڡ�������ʽ�����ڣ���ɱ�ת��Ϊ���ڣ��򷵻� True �����򣬷��� False )
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

  --λ����������Ϊ�Ƿ�ID

  IF Len(@ID) <> 15 AND Len(@ID) <> 18
 RETURN(0);

  --�����15λ���֤ ��ֻ��֤���ں��Ƿ����ָ�ʽ
  IF LEN(@ID)=15 
    IF ISDATE('19'+SUBSTRING(@ID,7,6))=0 OR ISNUMERIC(@ID)=0
      RETURN(0);
    ELSE
      RETURN(1);

  /*18λ���֤ ��֤���� У��λ */

    --��֤���ں�ǰ17λ�Ƿ����ָ�ʽ
  IF ISDATE(SUBSTRING(@ID,7,8))=0 OR ISNUMERIC(SUBSTRING(@ID,1,17))=0
 RETURN(0);

 --��֤У��λ��ʼ
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