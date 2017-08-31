USE [etest_zongbu]
GO
/****** Object:  UserDefinedFunction [dbo].[Fn_geshui_To_gongzi]    Script Date: 03/06/2017 14:30:37 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

----------- 个税 推 工资   (应该上的税(标准代缴费)  找 工资 )

ALTER  function [dbo].[Fn_geshui_To_gongzi] (@gs_djf decimal(18,2)) --@gs_djf个税的标准代缴费
returns decimal(18,2) as 
begin 
declare @id19 decimal(18,2)
SET @id19= 
case when @gs_djf <= 0 then cast(0+3500 as decimal(10,2))  
when @gs_djf >0 and @gs_djf <= 45 then cast(round(@gs_djf/3*100,2)+3500 as decimal(10,2))   
when @gs_djf >45 and @gs_djf <= 345 then cast(round((@gs_djf+105)/10*100,2)+3500 as decimal(10,2))   
when @gs_djf > 345 and @gs_djf <= 1245 then cast(round((@gs_djf+555)/20*100,2)+3500 as decimal(10,2))   
when @gs_djf > 1245 and @gs_djf <= 7745 then cast(round((@gs_djf+1005)/25*100,2)+3500 as decimal(10,2))   
when @gs_djf > 7745 and @gs_djf <= 13745 then cast(round((@gs_djf+2755)/30*100,2)+3500 as decimal(10,2))   
when @gs_djf >13745 and @gs_djf <= 22495 then cast(round((@gs_djf+5505)/35*100,2)+3500 as decimal(10,2))   
when @gs_djf >22495 then cast(round((@gs_djf+13505)/45*100,2)+3500 as decimal(10,2))   
end 
return @id19

END 



