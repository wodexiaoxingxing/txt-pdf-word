USE [etest_zongbu]
GO
/****** Object:  StoredProcedure [dbo].[proc_2015_qiye_update_LC_shebao_shebaoyewu_new]    Script Date: 03/06/2017 14:23:02 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER     PROCEDURE [dbo].[proc_2015_qiye_update_LC_shebao_shebaoyewu_new] 
@gerenId     VARCHAR(50),            -- ���(Ψһ��)
@workType    VARCHAR(50),   -- ��Ʒ����(�籣��Ʒ���������Ʒ���籣����....)
@UpdateType  VARCHAR(50), -- ��Ʒ���ͣ�ֻ�У���Ա ��Ա ȡ����
@dt          DATETIME,     -- ���̴����·�
@Cur_grNo    VARCHAR(50),--���� ���Ψһ
@Cur_qyNo VARCHAR(50)---��ҵΨһ���
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
--1ȡ����Ա����
--UPDATE [dbo].[2015_lc_gerenwork] SET workState = -1 ,workLog  = isnull(workLog+'[����]','')+'ϵͳȡ�����̣�' +CONVERT(varchar(100), GETDATE(), 120) WHERE typeName='�籣��Ա' AND  ProductID = @gerenId and workState = 0

IF EXISTS(SELECT * FROM [T_Lc_qiyework] WHERE workState = 0 AND DATEDIFF(m,workStarDate,@dt)=0 AND typeName='�籣��Ա' AND YGProNo= @gerenId)
--2�����̾͸���
--�籣ҵ��
UPDATE [T_Lc_qiyework] SET 
QyNo=gr_shiwu.QyNo,--��ҵ���
--QyName=gr_shiwu.QyName,---��ҵ����
depname=gr_shiwu.depname,--�ֲ� (��ҵ��)
QyName=gr_shiwu.QyName,--��ҵ������
diqu=gr_shiwu.qyArea,--��ҵ����
--qiyeGuanxi=gr_shiwu.guanxi,--������ϵ(��/��)
CompanyNo=gr_shiwu.CompanyNo_cp,--������˾���
CompanyName=gr_shiwu.CompanyName_cp,--������˾����
YGName=gr_shiwu.YGName,---Ա��������
Idcard=gr_shiwu.IDcard,----Ա����֤������
guanxi=gr_shiwu.guanxi,--������ҵ��ϵ(�Ƿ�)
--yewu_name=qyyewuRen,---ҵ��Ա
--kefu_name=qykefuRen,--�ͷ���Ա
workContent=isnull(cast(gr_shiwu.hukouType as varchar),'')+
',�籣'+isnull(cast(gr_shiwu.Ex_str1 as varchar),'')
+',����:'+
CASE WHEN gr_shiwu.Ex_int1 <> 2834 THEN 
'[��ʽ��ʼ]'+replace(isnull(cast(gr_shiwu.Ex_int1 as varchar),''),'.00','')+'[��ʽ����]'
ELSE
replace(isnull(cast(gr_shiwu.Ex_int1 as varchar),''),'.00','')
end
+',ҽ��:'+replace(isnull(cast(gr_shiwu.Ex_int2 as varchar),''),'.00','')
FROM [T_Lc_qiyework] AS wk
--V_Customer_geren_gerenExtended AS gr,
LEFT JOIN 
V_Customer_QiyeYuangongProduct AS gr_shiwu
ON wk.YGProNo=gr_shiwu.YGProNo
WHERE  --wk.yuangongId = gr.grNo  AND
  wk.workState = 0 AND DATEDIFF(m,wk.workStarDate,GETDATE())=0 AND wk.typeName='�籣��Ա' AND wk.YGProNo=@gerenId
ELSE
--3�����̾Ͳ���
insert  INTO [T_Lc_qiyework] 
        ( adddate,depname ,QyNo ,QyName ,diqu ,
        Guanxi ,
        CompanyNo ,CompanyName ,
        YGNo ,YGName ,Idcard,YGProNo ,
        typeName ,workInitDate  ,workLog ,
        last_Operation_Step ,last_Operation_name ,last_Operation_date  ,
        fh_flag ,M_zidong_flag ,M_qiangzhi_flag ,workState ,
        workStarDate ,workExecDate,
       -- yewu_name,yewu_date,
       -- kefu_name,kefu_date,
        workContent)
SELECT getdate(),gr_shiwu.DepName,QyNo,QyName,qyArea,
      guanxi,
       CompanyNo_cp,CompanyName_cp,
       YGNo,YGName,Idcard,@gerenId ,
       '�籣��Ա',GETDATE(),'��ʼ�����̡�'+CONVERT(varchar(100), GETDATE(), 120)+'[����]',
       0,'ϵͳ',GETDATE(),
       0,0,0,0,
       GETDATE(),GETDATE(),
     --  qyyewuRen,GETDATE(),
     --  qykefuRen,GETDATE(),
isnull(cast(gr_shiwu.hukouType as varchar),'')+
',�籣'+isnull(cast(gr_shiwu.Ex_str1 as varchar),'')
+',����:'+
CASE WHEN gr_shiwu.Ex_int1 <> 2834 THEN 
'[��ʽ��ʼ]'+replace(isnull(cast(gr_shiwu.Ex_int1 as varchar),''),'.00','')+'[��ʽ����]'
ELSE
replace(isnull(cast(gr_shiwu.Ex_int1 as varchar),''),'.00','')
end
+',ҽ��:'+replace(isnull(cast(gr_shiwu.Ex_int2 as varchar),''),'.00','')
from --dbo.V_Customer_geren_gerenExtended AS gr , 
V_Customer_QiyeYuangongProduct AS gr_shiwu
WHERE
-- gr.grNo = gr_shiwu.grNo AND 
gr_shiwu.YGProNo = @gerenId 
END

-------�� ִ�м�Ա��ͬ������--------------------------------------------------------------------
IF	@UpdateType = '��Ա'
begin
--1ȡ����Ա����
--UPDATE [dbo].[2015_lc_gerenwork] SET workState = -1 ,workLog  = isnull(workLog+'[����]','')+'ϵͳȡ�����̣�' +CONVERT(varchar(100), GETDATE(), 120) WHERE typeName='�籣��Ա' AND  ProductID = @gerenId and workState = 0
IF EXISTS(SELECT * FROM [T_Lc_qiyework] WHERE workState = 0 AND DATEDIFF(m,workStarDate,@dt)=0 AND typeName='�籣��Ա' AND YGProNo= @gerenId)
--2�����̾͸���
UPDATE [T_Lc_qiyework] SET 
QyNo=gr_shiwu.QyNo,--��ҵ���
depname=gr_shiwu.depname,--�ֲ� (��ҵ��)
QyName=gr_shiwu.QyName,--��ҵ������
diqu=gr_shiwu.qyArea,--��ҵ����
--qiyeGuanxi=gr_shiwu.guanxi,--������ϵ(��/��)
CompanyNo=gr_shiwu.CompanyNo_cp,--������˾���
CompanyName=gr_shiwu.CompanyName_cp,--������˾����
guanxi=gr_shiwu.guanxi,--������ҵ��ϵ(�Ƿ�)
YGName=gr_shiwu.YGName,---Ա��������
Idcard=gr_shiwu.IDcard,----Ա����֤������
yewu_name=qyyewuRen,---ҵ��Ա
kefu_name=qykefuRen,--�ͷ���Ա
workContent=isnull(cast(gr_shiwu.hukouType as varchar),'')+
',�籣'+isnull(cast(gr_shiwu.Ex_str1 as varchar),'')
+',����:'+
CASE WHEN gr_shiwu.Ex_int1 <> 2834 THEN 
'[��ʽ��ʼ]'+replace(isnull(cast(gr_shiwu.Ex_int1 as varchar),''),'.00','')+'[��ʽ����]'
ELSE
replace(isnull(cast(gr_shiwu.Ex_int1 as varchar),''),'.00','')
end
+',ҽ��:'+replace(isnull(cast(gr_shiwu.Ex_int2 as varchar),''),'.00','')
FROM [T_Lc_qiyework] AS wk
--V_Customer_geren_gerenExtended AS gr,
LEFT JOIN 
V_Customer_QiyeYuangongProduct AS gr_shiwu
ON wk.YGProNo=gr_shiwu.YGProNo
WHERE  --wk.yuangongId = gr.grNo  AND
  wk.workState = 0 AND DATEDIFF(m,wk.workStarDate,GETDATE())=0 AND wk.typeName='�籣��Ա' AND wk.YGProNo=@gerenId
ELSE
--3�����̾Ͳ���
insert  INTO [T_Lc_qiyework] 
        ( adddate,depname ,QyNo ,QyName ,diqu ,
        Guanxi ,
        CompanyNo ,CompanyName ,
        YGNo ,YGName ,Idcard,YGProNo ,
        typeName ,workInitDate  ,workLog ,
        last_Operation_Step ,last_Operation_name ,last_Operation_date  ,
        fh_flag ,M_zidong_flag ,M_qiangzhi_flag ,workState ,
        workStarDate ,workExecDate,
        yewu_name,yewu_date,
        kefu_name,kefu_date,
        workContent)
SELECT getdate(),gr_shiwu.DepName,QyNo,QyName,qyArea,
       guanxi,
       CompanyNo_cp,CompanyName_cp,
       YGNo,YGName,Idcard,@gerenId ,
       '�籣��Ա',GETDATE(),'��ʼ�����̡�'+CONVERT(varchar(100), GETDATE(), 120)+'[����]',
       0,'ϵͳ',GETDATE(),
       0,0,0,0,
       GETDATE(),GETDATE(),
       qyyewuRen,GETDATE(),
       qykefuRen,GETDATE(),
isnull(cast(gr_shiwu.hukouType as varchar),'')+
',�籣'+isnull(cast(gr_shiwu.Ex_str1 as varchar),'')
+',����:'+
CASE WHEN gr_shiwu.Ex_int1 <> 2834 THEN 
'[��ʽ��ʼ]'+replace(isnull(cast(gr_shiwu.Ex_int1 as varchar),''),'.00','')+'[��ʽ����]'
ELSE
replace(isnull(cast(gr_shiwu.Ex_int1 as varchar),''),'.00','')
end
+',ҽ��:'+replace(isnull(cast(gr_shiwu.Ex_int2 as varchar),''),'.00','')
from --dbo.V_Customer_geren_gerenExtended AS gr , 
V_Customer_QiyeYuangongProduct AS gr_shiwu
WHERE
-- gr.grNo = gr_shiwu.grNo AND 
gr_shiwu.YGProNo = @gerenId 
END
-------�� ִ��ȡ����ͬ������--------------------------------------------------------------------

IF	@UpdateType = 'ȡ��'
begin
--1ȡ����Ա ��Ա����
UPDATE [dbo].[T_Lc_qiyework] SET workState = -1 ,workLog  = isnull(workLog+'[����]','')+'ϵͳȡ�����̣�' +CONVERT(varchar(100), GETDATE(), 120) WHERE   YGProNo = @gerenId  and workstate=0 AND DATEDIFF(m,workStarDate,@dt)>=0
END
end

-------�籣ҵ�����----




end


