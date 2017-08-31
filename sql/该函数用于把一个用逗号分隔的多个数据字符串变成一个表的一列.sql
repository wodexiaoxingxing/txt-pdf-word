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
--该函数用于把一个用逗号分隔的多个数据字符串变成一个表的一列，例如字符串'1,2,3,4,5' 将编程一个表，这个表
Begin
set @str = @str+','
Declare @insertStr varchar(50) --截取后的第一个字符串
Declare @newstr varchar(1000) --截取第一个字符串后剩余的字符串
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