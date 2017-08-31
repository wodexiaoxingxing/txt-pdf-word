USE [etest_zongbu]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_ID_15_To_18]    Script Date: 03/06/2017 14:32:01 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO



ALTER function [dbo].[fn_ID_15_To_18] (@id15 char(18)) 
returns char(18) as 
begin 
--declare @id19 char(18)
declare @id20 char(18)
--SET @id20=@id15

IF LEN(@id15)=15
begin
declare @id18 char(18)
declare @s1 as integer
declare @s2 as integer
declare @s3 as integer
declare @s4 as integer
declare @s5 as integer
declare @s6 as integer
declare @s7 as integer
declare @s8 as integer
declare @s9 as integer
declare @s10 as integer
declare @s11 as integer
declare @s12 as integer
declare @s13 as integer
declare @s14 as integer
declare @s15 as integer
declare @s16 as integer
declare @s17 as integer
declare @s18 as integer

set @s1 = substring(@id15,1,1)
set @s2 = substring(@id15,2,1)
set @s3 = substring(@id15,3,1)
set @s4 = substring(@id15,4,1)
set @s5 = substring(@id15,5,1)
set @s6 = substring(@id15,6,1)
set @s7 = 1
set @s8 = 9
set @s9 = substring(@id15,7,1)
set @s10 = substring(@id15,8,1)
set @s11 = substring(@id15,9,1)
set @s12 = substring(@id15,10,1)
set @s13 = substring(@id15,11,1)
set @s14 = substring(@id15,12,1)
set @s15 = substring(@id15,13,1)
set @s16 = substring(@id15,14,1)
set @s17 = substring(@id15,15,1)

set @s18 = ( (@s1*7) + (@s2*9) + (@s3*10) + (@s4*5) + (@s5*8) + 
(@s6*4) + (@s7*2) + (@s8*1) + (@s9*6) + (@s10*3) + 
(@s11*7) + (@s12*9) + (@s13*10) + (@s14*5) + (@s15*8) + 
(@s16*4) + (@s17*2) ) % 11

set @id18 = substring(@id15,1,6) + '19' + substring(@id15,7,9) + 
case 
when @s18 = 0 then '1'
when @s18 = 1 then '0'
when @s18 = 2 then 'x'
when @s18 = 3 then '9'
when @s18 = 4 then '8'
when @s18 = 5 then '7'
when @s18 = 6 then '6'
when @s18 = 7 then '5'
when @s18 = 8 then '4'
when @s18 = 9 then '3'
when @s18 = 10 then '2'
end

set @id20= @id18
end
else 
BEGIN
 set @id20=@id15
end
return @id20
end


