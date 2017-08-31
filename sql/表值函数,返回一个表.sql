USE [etest_zongbu]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_geren_djf_yfgz_duocanshu]    Script Date: 03/06/2017 14:27:39 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

----------- 个人的代发工资业务  代缴费 推 应发工资 

ALTER     function [dbo].[fn_geren_djf_yfgz_duocanshu] (@gz_djf decimal(18,2)) --@gz_djf  个人产品的   标准代缴费
returns @TempTable table(canbaojin decimal(18,2),geshui decimal(18,2),daoshougongzi decimal(18,2),yingfagongzi decimal(18,2))
as 
begin 
------------------------------------------=================得到社保最低 基数 跟比例=======
declare @yanglaoConst decimal(18,2)---基础的  养老基数
declare @shiyeconst decimal(18,2)---基础的  失业基数
declare @YiLaoConst decimal(18,2)--基础的 医疗
declare @yanglao_geren decimal(18,2)--基础的 养老比例
declare @shiye_geren decimal(18,2)--基础的  失业比例
declare @yiliao_geren decimal(18,2)--基础的  医疗比例

SELECT @yanglaoConst=c.yanglaoConst,@shiyeconst=c.shiyeconst,@YiLaoConst=c.YiLaoConst,
@yanglao_geren=d.yanglao_geren,@shiye_geren=d.shiye_geren,@yiliao_geren=d.yiliao_geren  FROM
etest_zongbu.dbo.Const AS c
CROSS JOIN 
etest_zongbu..T_shebao_jiaofei_bili AS d
 where  
c.ConstType = 1 --得到计算基数
--------------------================================================================================
declare @canbaojin decimal(18,2)--残保金
declare @geshui decimal(18,2)--个税
declare @daoshougongzi decimal(18,2)--到手工资
declare @yingfagongzi decimal(18,2)--应发工资
declare @shebao decimal(18,2)--社保
DECLARE @jisuan_geshui decimal(18,2) --计算个税 使用 
declare @id19 decimal(18,2)--x（1+0.017）---中间变量 

--declare @id18 decimal(18,2)--社保（x）

  
SET @yingfagongzi=@gz_djf+@gz_djf*0.1
 

------------------------------------------------=========================计算 应发工资 
WHILE @id19 <> @gz_djf
BEGIN


SET @id19=(
SELECT --Ex_int1,Ex_int2,
--c.yanglaoConst,c.shiyeconst,c.YiLaoConst,d.yanglao_geren,d.shiye_geren,d.yiliao_geren,
CAST(ROUND(1.017* @yingfagongzi, 2) AS numeric(18, 2))
-
(
CAST(ROUND(@yanglao_geren/100 * dbo.Getmax(@yingfagongzi, @yanglaoConst), 2) AS numeric(18, 2))  --AS  养老个人
+CAST(ROUND(@shiye_geren/100 * dbo.Getmax(@yingfagongzi, @shiyeconst), 2) AS numeric(18, 2))  --as 失业个人--户口城镇
+CAST(ROUND(@yiliao_geren/100 * dbo.Getmax(@yingfagongzi, @YiLaoConst) + 3, 2) AS numeric(18, 2))
) as 社保
)
IF @id19<@gz_djf --AND @gz_djf>=100
BEGIN
SET @yingfagongzi=@yingfagongzi+@gz_djf*0.1
END 
 

IF @id19>@gz_djf --AND @gz_djf>=100
BEGIN
SET @yingfagongzi=@yingfagongzi-0.01
END 


END 

------------------------======================社保
SET @shebao=
(SELECT (
CAST(ROUND(@yanglao_geren/100 * dbo.Getmax(@yingfagongzi, @yanglaoConst), 2) AS numeric(18, 2))  --AS  养老个人
+CAST(ROUND(@shiye_geren/100 * dbo.Getmax(@yingfagongzi, @shiyeconst), 2) AS numeric(18, 2))  --as 失业个人--户口城镇
+CAST(ROUND(@yiliao_geren/100 * dbo.Getmax(@yingfagongzi, @YiLaoConst) + 3, 2) AS numeric(18, 2))
) as 社保
)
--------------------------------------====================残保金
SET @canbaojin= (select CAST(ROUND(0.017* @yingfagongzi, 2) AS numeric(18, 2)))
--------------------------------------------------=========个税
SET @jisuan_geshui=@yingfagongzi-@shebao

SET @geshui=etest_zongbu.dbo.Fn_gongzi_To_geshui(@jisuan_geshui)
----=======================================================到手工资
SET @daoshougongzi=@yingfagongzi-@geshui-@shebao
insert into @TempTable--(canbaojin, geshui,daoshougongzi,yingfagongzi)
select @canbaojin, @geshui,@daoshougongzi,@yingfagongzi 
--return 

return --@TempTable table(canbaojin decimal(18,2),geshui decimal(18,2),daoshougongzi decimal(18,2),yingfagongzi decimal(18,2))
END 


--Drop FUNCTION [dbo].[fn_geren_djf_yfgz_duocanshu] 