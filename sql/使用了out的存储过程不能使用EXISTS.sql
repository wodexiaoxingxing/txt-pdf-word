USE [etest_zongbu]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER      PROCEDURE [dbo].[proc_2017_geren_update_LC_shebao_shebaoyewu_new] 
@gerenId     VARCHAR(50), -- ���
@workType    VARCHAR(50), -- ��Ʒ����(�籣��Ʒ���������Ʒ���籣����....)
@UpdateType  VARCHAR(50), -- ��Ʒ���ͣ�ֻ�У���Ա ��Ա ȡ����
@dt          DATETIME,   -- ���̴����·�
@Cur_grNo    VARCHAR(50)--���� ���Ψһ
AS
BEGIN 
/*
��һ����ȷ������ͬ�����ͣ���Ա  ��Ա  ȡ����
�ڶ���������ͬ������ִ�в���
*/


/* Ϊ�˿����洢���̵���ִ�ж�Ԥ��������ͬ�������֮��ֱ��ɾ��
USE etest
DECLARE @dt DATETIME 
DECLARE @gerenId INT            -- ���˿ͻ�ID
DECLARE @workType  VARCHAR(50)  -- ��Ʒ����(�籣��Ʒ���������Ʒ���籣����....)
DECLARE @UpdateType VARCHAR(50) -- ��Ʒ���ͣ�ֻ�У���Ա ��Ա ȡ����
SET @dt = GETDATE()
SET @gerenId = 20
SET @workType = '�籣��Ʒ'
SET @UpdateType = '��Ա'
*/



------- ִ����Ա��ͬ������--------�籣------------------------------------------------------------
IF	@workType = 'proNo_shebao'
begin
------- ִ����Ա��ͬ������--------------------------------------------------------------------
IF	@UpdateType = '��Ա'
BEGIN


IF   (SELECT COUNT(*) FROM etest_zongbu.dbo.T_Lc_gerenwork_2017 WHERE workState = 0 AND DATEDIFF(m,@dt,workStarDate)<=0 AND typeName='�籣��Ա' AND ProductID= @gerenId)>0
--2�����̾͸���
--�籣ҵ��
BEGIN 

UPDATE etest_zongbu.dbo.T_Lc_gerenwork_2017 SET 
depname=gr_shiwu.depname,---��Ʒ���ڲ���
yuangongName=gr_shiwu.Name,--����
yuangongIdCard=gr_shiwu.IDcard,--���֤��
CompanyNo=gr_shiwu.CompanyNo,--������˾
qiyeName= qidu_gs.YijieCompanyName,--������˾
diqu= qidu_gs.yijie_qyarea,---����
qiyeGuanxi= '��',---������ϵ��
qiyeGuanxi_name=qidu_gs.YijieCompanyName,--������ϵ 
workContent=isnull(cast(gr_shiwu.hukouType as varchar),'')+
',�籣'+isnull(cast(gr_shiwu.Ex_str1 as varchar),'')
+',����:'+
CASE WHEN gr_shiwu.Ex_int1 <> 3082 THEN 
'[��ʽ��ʼ]'+replace(isnull(cast(gr_shiwu.Ex_int1 as varchar),''),'.00','')+'[��ʽ����]'
ELSE
replace(isnull(cast(gr_shiwu.Ex_int1 as varchar),''),'.00','')
end
+',ҽ��:'+replace(isnull(cast(gr_shiwu.Ex_int2 as varchar),''),'.00','')

FROM etest_zongbu.dbo.T_Lc_gerenwork_2017 AS wk
LEFT JOIN 
etest_zongbu..V_Customer_geren_gerenExtended_GerenProduct_Curr AS gr_shiwu
ON wk.ProductID=gr_shiwu.grProNo
 LEFT JOIN etest_zongbu..Base_YijieCompany AS qidu_gs
ON gr_shiwu.CompanyNo=qidu_gs.YijieCompanyCode
WHERE  
  wk.workState = 0 AND DATEDIFF(m,wk.workStarDate,GETDATE())=0 AND wk.typeName='�籣��Ա' AND wk.ProductID=@gerenId
 END 
ELSE
BEGIN 
--PRINT @gerenId
--RETURN 
--PRINT '5555555'
--RETURN 1
--3�����̾Ͳ���
---����Ψһ���
DECLARE @var VARCHAR(50) ;
exec etest_zongbu.dbo.Pr_Base_GetNewNo @var OUTPUT,'grrz'
insert  INTO etest_zongbu.dbo.T_Lc_gerenwork_2017 
        (
        is_zj_leixing,----����Ա���ͣ���Ա1 ��Ա2��
        rz_no,---��־Ψһ���
        Cur_Operation_Step,---��ǰ�������裨STEP1000����������
        Cur_Operation_M_Flag,--��ǰ��������֤  int 
        Cur_Operation_name,
       -- Cur_Operation_Stardate,---��ǰ���迪ʼʱ��
        TypeNo,--��־�����־ ��TYPE000��TYPE001������
        yewu_M_Flag,--ҵ��Ա �Ƿ���Ҫ ��Ǯ��֤
        kefu_M_Flag,---�ͷ� �Ƿ���Ҫ ��Ǯ��֤
        shenhe_M_Flag,---����� �Ƿ���ҪǮ��
        shiwu_zhuanyuan_M_Flag,--����רԱ �Ƿ���ҪǮ��
        shiwu_zhuli_M_Flag,--�������� �Ƿ���ҪǮ��
        yewu_jingli_M_Flag,---�ͷ����� �Ƿ���ҪǮ
         adddate,--��־����ʱ��
         
        CompanyNo,depname ,qiyeId ,qiyeName ,diqu ,qiyeGuanxi ,qiyeGuanxi_name ,yuangongId ,yuangongName ,yuangongIdCard ,ProductID ,
        typeName ,workInitDate  ,workLog ,
       -- last_Operation_Step ,last_Operation_name ,last_Operation_date ,Ex_flag , fh_flag ,
        M_zidong_flag ,M_qiangzhi_flag ,workState ,workStarDate ,workExecDate,workContent)
SELECT 
1,
@var,
'STEP1000',
0,
gr_shiwu.yewuName,----����Ϊҵ��Ա������
--GETDATE(),
'TYPE001',
0,
0,
0,
1,
1,
1,
GETDATE(),

gr_shiwu.CompanyNo,gr_shiwu.DepName,0,qidu_gs.YijieCompanyName,qidu_gs.yijie_qyarea,'��',qidu_gs.YijieCompanyName,gr_shiwu.grNo,gr_shiwu.name,gr_shiwu.IDcard,@gerenId ,
       '�籣��Ա',GETDATE(),'��ʼ�����̡�'+CONVERT(varchar(100), GETDATE(), 120)+'[����]',
     --  0,'ϵͳ',GETDATE(),NULL,0,
       0,0,0,GETDATE(),GETDATE(),
isnull(cast(gr_shiwu.hukouType as varchar),'')+
',�籣'+isnull(cast(gr_shiwu.Ex_str1 as varchar),'')
+',����:'+
CASE WHEN gr_shiwu.Ex_int1 <> 3082 THEN 
'[��ʽ��ʼ]'+replace(isnull(cast(gr_shiwu.Ex_int1 as varchar),''),'.00','')+'[��ʽ����]'
ELSE
replace(isnull(cast(gr_shiwu.Ex_int1 as varchar),''),'.00','')
end
+',ҽ��:'+replace(isnull(cast(gr_shiwu.Ex_int2 as varchar),''),'.00','')
from 
etest_zongbu..V_Customer_geren_gerenExtended_GerenProduct_Curr AS gr_shiwu
LEFT JOIN etest_zongbu..Base_YijieCompany AS qidu_gs
ON 
gr_shiwu.CompanyNo=qidu_gs.YijieCompanyCode
WHERE
gr_shiwu.grProNo = @gerenId 
END 

END

-------�� ִ�м�Ա��ͬ������--------------------------------------------------------------------
IF	@UpdateType = '��Ա'
begin

IF (SELECT COUNT(*) FROM etest_zongbu.dbo.T_Lc_gerenwork_2017 WHERE workState = 0 AND DATEDIFF(m,@dt,workStarDate)<=0 AND typeName='�籣��Ա' AND ProductID= @gerenId)>0
BEGIN 
--2�����̾͸���
UPDATE etest_zongbu.dbo.T_Lc_gerenwork_2017 SET
 yuangongName=gr_shiwu.name,
 yuangongIdCard=gr_shiwu.IDcard,
CompanyNo=gr_shiwu.CompanyNo,
qiyeName= qidu_gs.YijieCompanyName,
diqu= qidu_gs.yijie_qyarea,
qiyeGuanxi= '��',
qiyeGuanxi_name=qidu_gs.YijieCompanyName, 
workContent=isnull(cast(gr_shiwu.hukouType as varchar),'')+
',�籣'+isnull(cast(gr_shiwu.Ex_str1 as varchar),'')
+',����:'+
CASE WHEN gr_shiwu.Ex_int1 <> 3082 THEN 
'[��ʽ��ʼ]'+replace(isnull(cast(gr_shiwu.Ex_int1 as varchar),''),'.00','')+'[��ʽ����]'
ELSE
replace(isnull(cast(gr_shiwu.Ex_int1 as varchar),''),'.00','')
end
+',ҽ��:'+replace(isnull(cast(gr_shiwu.Ex_int2 as varchar),''),'.00','')
FROM etest_zongbu.dbo.T_Lc_gerenwork_2017 AS wk
LEFT JOIN 
etest_zongbu..V_Customer_geren_gerenExtended_GerenProduct_Curr AS gr_shiwu
ON wk.ProductID=gr_shiwu.grProNo
LEFT JOIN etest_zongbu..Base_YijieCompany AS qidu_gs
ON 
gr_shiwu.CompanyNo=qidu_gs.YijieCompanyCode
WHERE  
  wk.workState = 0 AND DATEDIFF(m,wk.workStarDate,GETDATE())=0 AND wk.typeName='�籣��Ա' AND wk.ProductID=@gerenId
  END 
ELSE
BEGIN
--3�����̾Ͳ���
---����Ψһ���
--SELECT * FROM  etest_zongbu.dbo.T_base_ControlNewNo 
DECLARE @var1 VARCHAR(50) ;
exec etest_zongbu.dbo.Pr_Base_GetNewNo @var1 OUTPUT,'grrz'
insert  INTO etest_zongbu.dbo.T_Lc_gerenwork_2017 
        (  is_zj_leixing,----����Ա���ͣ���Ա1 ��Ա2��
         rz_no,---��־Ψһ���
        Cur_Operation_Step,---��ǰ�������裨STEP1000����������
        Cur_Operation_M_Flag,--��ǰ��������֤  int 
        Cur_Operation_name,
      --  Cur_Operation_Stardate,---��ǰ���迪ʼʱ��
        TypeNo,--��־�����־ ��TYPE000��TYPE001������
        yewu_M_Flag,--ҵ��Ա �Ƿ���Ҫ ��Ǯ��֤
        kefu_M_Flag,---�ͷ� �Ƿ���Ҫ ��Ǯ��֤
        shenhe_M_Flag,---����� �Ƿ���ҪǮ��
        shiwu_zhuanyuan_M_Flag,--����רԱ �Ƿ���ҪǮ��
        shiwu_zhuli_M_Flag,--�������� �Ƿ���ҪǮ��
        yewu_jingli_M_Flag,---�ͷ����� �Ƿ���ҪǮ
        adddate,--��־����ʱ��
        CompanyNo,depname ,qiyeId ,qiyeName ,diqu ,qiyeGuanxi ,qiyeGuanxi_name ,yuangongId ,yuangongName ,yuangongIdCard ,ProductID ,
        typeName ,workInitDate  ,workLog ,
      --  last_Operation_Step ,last_Operation_name ,last_Operation_date ,Ex_flag , fh_flag ,
        M_zidong_flag ,M_qiangzhi_flag ,workState ,workStarDate ,workExecDate,workContent)
SELECT 
2,
@var1,
'STEP2000',
0,
gr_shiwu.kefuName,
--GETDATE(),
'TYPE002',
0,
0,
0,
0,
0,
0,
GETDATE(),

gr_shiwu.CompanyNo,gr_shiwu.DepName,0,qidu_gs.YijieCompanyName,qidu_gs.yijie_qyarea,'��',qidu_gs.YijieCompanyName,gr_shiwu.grNo,gr_shiwu.name,gr_shiwu.IDcard,@gerenId ,
'�籣��Ա',GETDATE(),'��ʼ�����̡�'+CONVERT(varchar(100), GETDATE(), 120)+'[����]',
--- 0,'ϵͳ',GETDATE(),NULL,0,
 0,0,0,GETDATE(),GETDATE(),
isnull(cast(gr_shiwu.hukouType as varchar),'')+
',�籣'+isnull(cast(gr_shiwu.Ex_str1 as varchar),'')
+',����:'+
CASE WHEN gr_shiwu.Ex_int1 <> 3082 THEN 
'[��ʽ��ʼ]'+replace(isnull(cast(gr_shiwu.Ex_int1 as varchar),''),'.00','')+'[��ʽ����]'
ELSE
replace(isnull(cast(gr_shiwu.Ex_int1 as varchar),''),'.00','')
end
+',ҽ��:'+replace(isnull(cast(gr_shiwu.Ex_int2 as varchar),''),'.00','')
from 
 etest_zongbu..V_Customer_geren_gerenExtended_GerenProduct_Curr AS gr_shiwu
 LEFT JOIN etest_zongbu..Base_YijieCompany AS qidu_gs
ON 
gr_shiwu.CompanyNo=qidu_gs.YijieCompanyCode
WHERE 
gr_shiwu.grProNo = @gerenId 
END 

END
-------�� ִ��ȡ����ͬ������--------------------------------------------------------------------

IF	@UpdateType = 'ȡ��'
BEGIN

------------------------------------------------------������־----��ʼ---------------------------------------------
DECLARE @typename VARCHAR(50)
DECLARE @rz_no VARCHAR(50)--���̱������Ψһ���
DECLARE @Cur_count INT--����
DECLARE @star_date DATETIME
DECLARE @Cur_dt DATETIME
SET @Cur_dt = GETDATE()  
 -----------�õ�����Ψһ���---
 SELECT
  rz_no ,---���̱������Ψһ���
  typename--��־����
 INTO #temp_geren
 FROM 
 etest_zongbu.dbo.T_Lc_gerenwork_2017 WHERE 
  ProductID = @gerenId  and workstate=0 AND DATEDIFF(m,@dt,workStarDate)<=0
 AND TypeNo<>'TYPE009'---����ȡ��ת���°����
 
 SELECT TOP 1 @rz_no=rz_no,@typename=typename
 from #temp_geren
 WHERE 1=1  
 ORDER BY rz_no ASC

 SELECT @Cur_count=COUNT(*) from #temp_geren 
-------------------��ʼѭ��
WHILE @Cur_count > 0 
BEGIN

IF (SELECT COUNT(*) FROM etest_zongbu..T_lc_gerenwork_log_2017 WHERE rz_no=@rz_no)>0
BEGIN 

---�õ���һ����־����ʱ�� 
SELECT @star_date=MAX(caozuo_date) FROM etest_zongbu..T_lc_gerenwork_log_2017 WHERE rz_no=@rz_no
---��־�������������
INSERT INTO etest_zongbu..T_lc_gerenwork_log_2017
(typename,rz_no,caozuo_name,caozuo_date,star_date,step_no,button_no,is_kehu_flag,is_yewu_flag,is_jixiao_flag,adddate,worktxt)
SELECT typename,rz_no,'ϵͳ',@Cur_dt,@star_date,Cur_Operation_Step,'BUTTON1000',1,1,0,@Cur_dt,
(SELECT replace(geren_beizhu,'[ҵ������]',@typename)  FROM etest_zongbu..T_lc_gerenwork_button_2017 WHERE button_no='BUTTON1000' AND  is_geren=1)
 FROM etest_zongbu..T_Lc_gerenwork_2017 WHERE rz_no=@rz_no AND workState=0

END 

delete #temp_geren where rz_no= @rz_no
SET @Cur_count = 0

SELECT TOP 1 @rz_no=rz_no,@typename=typename
from #temp_geren
WHERE 1=1  
ORDER BY rz_no ASC

SELECT @Cur_count=COUNT(*) from #temp_geren

END 
-------------------ѭ������
DROP TABLE #temp_geren

------------------------------------------------------������־----����---------------------------------------------

--1ȡ����Ա ��Ա����
UPDATE etest_zongbu.dbo.T_Lc_gerenwork_2017 SET workState = -1 ,workLog  = isnull(workLog+'[����]','')+'ϵͳȡ�����̣�' +CONVERT(varchar(100), GETDATE(), 120)
 WHERE
 ProductID = @gerenId  and workstate=0 AND DATEDIFF(m,@dt,workStarDate)<=0
 AND TypeNo<>'TYPE009'---����ȡ��ת���°����
 ----
 
 
END



END

-------���----

---------------------------------------------------------------------������-------------------
---1.�ͷ����� 
UPDATE etest_zongbu.dbo.[T_Lc_gerenwork_2017] SET yewu_jingli_name='�徴' WHERE workstate = 0 AND typename IN ('�籣��Ա','�籣��Ա') AND ISNULL(yewu_jingli_name,'')=''
---2.ҵ����Ա
update etest_zongbu.dbo.[T_Lc_gerenwork_2017]  set yewu_name =a.yewuName from etest_zongbu..V_Customer_geren_gerenExtended_GerenProduct_Curr AS a
where a.grProNo = productid and  isnull(yewu_name,'') <> a.yewuName  and   workstate = 0 and a.ActFalg=1
AND typename IN ('�籣��Ա') 
--3.�ͷ���Ա
update etest_zongbu.dbo.[T_Lc_gerenwork_2017]  set kefu_name =a.kefuName from etest_zongbu..V_Customer_geren_gerenExtended_GerenProduct_Curr AS a  
where a.grProNo = productid and  isnull(kefu_name,'') <> a.kefuName and   workstate = 0 and a.ActFalg=1
AND typename IN ('�籣��Ա','�籣��Ա') 
--4.��������
update  etest_zongbu.dbo.[T_Lc_gerenwork_2017]  set shiwu_zhuli_name = etest_zongbu..com_diqu.name 
from etest_zongbu..com_diqu where  workstate = 0 AND  ISNULL(shiwu_zhuli_name,'') <> etest_zongbu..com_diqu.name
 AND   etest_zongbu..com_diqu.diqu = etest_zongbu.dbo.[T_Lc_gerenwork_2017].diqu
AND typename IN ('�籣��Ա','�籣��Ա') 

END

 

GO
