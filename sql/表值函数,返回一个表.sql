USE [etest_zongbu]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_geren_djf_yfgz_duocanshu]    Script Date: 03/06/2017 14:27:39 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

----------- ���˵Ĵ�������ҵ��  ���ɷ� �� Ӧ������ 

ALTER     function [dbo].[fn_geren_djf_yfgz_duocanshu] (@gz_djf decimal(18,2)) --@gz_djf  ���˲�Ʒ��   ��׼���ɷ�
returns @TempTable table(canbaojin decimal(18,2),geshui decimal(18,2),daoshougongzi decimal(18,2),yingfagongzi decimal(18,2))
as 
begin 
------------------------------------------=================�õ��籣��� ���� ������=======
declare @yanglaoConst decimal(18,2)---������  ���ϻ���
declare @shiyeconst decimal(18,2)---������  ʧҵ����
declare @YiLaoConst decimal(18,2)--������ ҽ��
declare @yanglao_geren decimal(18,2)--������ ���ϱ���
declare @shiye_geren decimal(18,2)--������  ʧҵ����
declare @yiliao_geren decimal(18,2)--������  ҽ�Ʊ���

SELECT @yanglaoConst=c.yanglaoConst,@shiyeconst=c.shiyeconst,@YiLaoConst=c.YiLaoConst,
@yanglao_geren=d.yanglao_geren,@shiye_geren=d.shiye_geren,@yiliao_geren=d.yiliao_geren  FROM
etest_zongbu.dbo.Const AS c
CROSS JOIN 
etest_zongbu..T_shebao_jiaofei_bili AS d
 where  
c.ConstType = 1 --�õ��������
--------------------================================================================================
declare @canbaojin decimal(18,2)--�б���
declare @geshui decimal(18,2)--��˰
declare @daoshougongzi decimal(18,2)--���ֹ���
declare @yingfagongzi decimal(18,2)--Ӧ������
declare @shebao decimal(18,2)--�籣
DECLARE @jisuan_geshui decimal(18,2) --�����˰ ʹ�� 
declare @id19 decimal(18,2)--x��1+0.017��---�м���� 

--declare @id18 decimal(18,2)--�籣��x��

  
SET @yingfagongzi=@gz_djf+@gz_djf*0.1
 

------------------------------------------------=========================���� Ӧ������ 
WHILE @id19 <> @gz_djf
BEGIN


SET @id19=(
SELECT --Ex_int1,Ex_int2,
--c.yanglaoConst,c.shiyeconst,c.YiLaoConst,d.yanglao_geren,d.shiye_geren,d.yiliao_geren,
CAST(ROUND(1.017* @yingfagongzi, 2) AS numeric(18, 2))
-
(
CAST(ROUND(@yanglao_geren/100 * dbo.Getmax(@yingfagongzi, @yanglaoConst), 2) AS numeric(18, 2))  --AS  ���ϸ���
+CAST(ROUND(@shiye_geren/100 * dbo.Getmax(@yingfagongzi, @shiyeconst), 2) AS numeric(18, 2))  --as ʧҵ����--���ڳ���
+CAST(ROUND(@yiliao_geren/100 * dbo.Getmax(@yingfagongzi, @YiLaoConst) + 3, 2) AS numeric(18, 2))
) as �籣
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

------------------------======================�籣
SET @shebao=
(SELECT (
CAST(ROUND(@yanglao_geren/100 * dbo.Getmax(@yingfagongzi, @yanglaoConst), 2) AS numeric(18, 2))  --AS  ���ϸ���
+CAST(ROUND(@shiye_geren/100 * dbo.Getmax(@yingfagongzi, @shiyeconst), 2) AS numeric(18, 2))  --as ʧҵ����--���ڳ���
+CAST(ROUND(@yiliao_geren/100 * dbo.Getmax(@yingfagongzi, @YiLaoConst) + 3, 2) AS numeric(18, 2))
) as �籣
)
--------------------------------------====================�б���
SET @canbaojin= (select CAST(ROUND(0.017* @yingfagongzi, 2) AS numeric(18, 2)))
--------------------------------------------------=========��˰
SET @jisuan_geshui=@yingfagongzi-@shebao

SET @geshui=etest_zongbu.dbo.Fn_gongzi_To_geshui(@jisuan_geshui)
----=======================================================���ֹ���
SET @daoshougongzi=@yingfagongzi-@geshui-@shebao
insert into @TempTable--(canbaojin, geshui,daoshougongzi,yingfagongzi)
select @canbaojin, @geshui,@daoshougongzi,@yingfagongzi 
--return 

return --@TempTable table(canbaojin decimal(18,2),geshui decimal(18,2),daoshougongzi decimal(18,2),yingfagongzi decimal(18,2))
END 


--Drop FUNCTION [dbo].[fn_geren_djf_yfgz_duocanshu] 