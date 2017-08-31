USE [etest_zongbu]
GO
/****** Object:  UserDefinedFunction [dbo].[StrToTable]    Script Date: 03/06/2017 14:29:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER Function [dbo].[StrToTable](@str varchar(1000))
Returns @tableName Table
(
   str2table varchar(50)
)
As
--�ú������ڰ�һ���ö��ŷָ��Ķ�������ַ������һ�����һ�У������ַ���'1,2,3,4,5' �����һ���������
Begin
set @str = @str+','
Declare @insertStr varchar(50) --��ȡ��ĵ�һ���ַ���
Declare @newstr varchar(1000) --��ȡ��һ���ַ�����ʣ����ַ���
set @insertStr = left(@str,charindex(',',@str)-1)
set @newstr = stuff(@str,1,charindex(',',@str),'')
Insert @tableName Values(@insertStr)
while(len(@newstr)>0)
begin
   set @insertStr = left(@newstr,charindex(',',@newstr)-1)
   Insert @tableName Values(@insertStr)
   set @newstr = stuff(@newstr,1,charindex(',',@newstr),'')
end
Return
End