USE [etest_zongbu]
GO
/****** Object:  StoredProcedure [dbo].[proc_2015_qiye_update_LC_shebao_shebaoyewu_new]    Script Date: 03/06/2017 14:23:02 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER     PROCEDURE [dbo].[proc_2015_qiye_update_LC_shebao_shebaoyewu_new] 
@gerenId     VARCHAR(50),            -- 编号(唯一的)
@workType    VARCHAR(50),   -- 产品类型(社保产品，公积金产品，社保补缴....)
@UpdateType  VARCHAR(50), -- 产品类型（只有：增员 减员 取消）
@dt          DATETIME,     -- 流程处理月份
@Cur_grNo    VARCHAR(50),--个人 编号唯一
@Cur_qyNo VARCHAR(50)---企业唯一编号
AS
BEGIN 
/*
第一步，确定流程同步类型（增员  减员  取消）
第二步，根据同步类型执行操作
*/


/* 为了拷贝存储过程单独执行而预留，所有同步都完成之后，直接删除
USE etest
DECLARE @dt DATETIME 
DECLARE @gerenId INT            -- 个人客户ID
DECLARE @workType  VARCHAR(50)  -- 产品类型(社保产品，公积金产品，社保补缴....)
DECLARE @UpdateType VARCHAR(50) -- 产品类型（只有：增员 减员 取消）
SET @dt = GETDATE()
SET @gerenId = 20
SET @workType = '社保产品'
SET @UpdateType = '增员'
*/



------- 执行增员，同步数据--------社保------------------------------------------------------------
IF	@workType = 'proNo_shebao'
begin
------- 执行增员，同步数据--------------------------------------------------------------------
IF	@UpdateType = '增员'
BEGIN
--1取消减员流程
--UPDATE [dbo].[2015_lc_gerenwork] SET workState = -1 ,workLog  = isnull(workLog+'[换行]','')+'系统取消流程！' +CONVERT(varchar(100), GETDATE(), 120) WHERE typeName='社保减员' AND  ProductID = @gerenId and workState = 0

IF EXISTS(SELECT * FROM [T_Lc_qiyework] WHERE workState = 0 AND DATEDIFF(m,workStarDate,@dt)=0 AND typeName='社保增员' AND YGProNo= @gerenId)
--2有流程就更新
--社保业务
UPDATE [T_Lc_qiyework] SET 
QyNo=gr_shiwu.QyNo,--企业编号
--QyName=gr_shiwu.QyName,---企业名称
depname=gr_shiwu.depname,--分部 (企业的)
QyName=gr_shiwu.QyName,--企业的名字
diqu=gr_shiwu.qyArea,--企业区县
--qiyeGuanxi=gr_shiwu.guanxi,--隶属关系(是/否)
CompanyNo=gr_shiwu.CompanyNo_cp,--隶属公司编号
CompanyName=gr_shiwu.CompanyName_cp,--隶属公司名称
YGName=gr_shiwu.YGName,---员工的名字
Idcard=gr_shiwu.IDcard,----员工的证件号码
guanxi=gr_shiwu.guanxi,--隶属企业关系(是否)
--yewu_name=qyyewuRen,---业务员
--kefu_name=qykefuRen,--客服人员
workContent=isnull(cast(gr_shiwu.hukouType as varchar),'')+
',社保'+isnull(cast(gr_shiwu.Ex_str1 as varchar),'')
+',养老:'+
CASE WHEN gr_shiwu.Ex_int1 <> 2834 THEN 
'[样式开始]'+replace(isnull(cast(gr_shiwu.Ex_int1 as varchar),''),'.00','')+'[样式结束]'
ELSE
replace(isnull(cast(gr_shiwu.Ex_int1 as varchar),''),'.00','')
end
+',医疗:'+replace(isnull(cast(gr_shiwu.Ex_int2 as varchar),''),'.00','')
FROM [T_Lc_qiyework] AS wk
--V_Customer_geren_gerenExtended AS gr,
LEFT JOIN 
V_Customer_QiyeYuangongProduct AS gr_shiwu
ON wk.YGProNo=gr_shiwu.YGProNo
WHERE  --wk.yuangongId = gr.grNo  AND
  wk.workState = 0 AND DATEDIFF(m,wk.workStarDate,GETDATE())=0 AND wk.typeName='社保增员' AND wk.YGProNo=@gerenId
ELSE
--3无流程就插入
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
       '社保增员',GETDATE(),'初始化流程。'+CONVERT(varchar(100), GETDATE(), 120)+'[换行]',
       0,'系统',GETDATE(),
       0,0,0,0,
       GETDATE(),GETDATE(),
     --  qyyewuRen,GETDATE(),
     --  qykefuRen,GETDATE(),
isnull(cast(gr_shiwu.hukouType as varchar),'')+
',社保'+isnull(cast(gr_shiwu.Ex_str1 as varchar),'')
+',养老:'+
CASE WHEN gr_shiwu.Ex_int1 <> 2834 THEN 
'[样式开始]'+replace(isnull(cast(gr_shiwu.Ex_int1 as varchar),''),'.00','')+'[样式结束]'
ELSE
replace(isnull(cast(gr_shiwu.Ex_int1 as varchar),''),'.00','')
end
+',医疗:'+replace(isnull(cast(gr_shiwu.Ex_int2 as varchar),''),'.00','')
from --dbo.V_Customer_geren_gerenExtended AS gr , 
V_Customer_QiyeYuangongProduct AS gr_shiwu
WHERE
-- gr.grNo = gr_shiwu.grNo AND 
gr_shiwu.YGProNo = @gerenId 
END

-------二 执行减员，同步数据--------------------------------------------------------------------
IF	@UpdateType = '减员'
begin
--1取消增员流程
--UPDATE [dbo].[2015_lc_gerenwork] SET workState = -1 ,workLog  = isnull(workLog+'[换行]','')+'系统取消流程！' +CONVERT(varchar(100), GETDATE(), 120) WHERE typeName='社保增员' AND  ProductID = @gerenId and workState = 0
IF EXISTS(SELECT * FROM [T_Lc_qiyework] WHERE workState = 0 AND DATEDIFF(m,workStarDate,@dt)=0 AND typeName='社保减员' AND YGProNo= @gerenId)
--2有流程就更新
UPDATE [T_Lc_qiyework] SET 
QyNo=gr_shiwu.QyNo,--企业编号
depname=gr_shiwu.depname,--分部 (企业的)
QyName=gr_shiwu.QyName,--企业的名字
diqu=gr_shiwu.qyArea,--企业区县
--qiyeGuanxi=gr_shiwu.guanxi,--隶属关系(是/否)
CompanyNo=gr_shiwu.CompanyNo_cp,--隶属公司编号
CompanyName=gr_shiwu.CompanyName_cp,--隶属公司名称
guanxi=gr_shiwu.guanxi,--隶属企业关系(是否)
YGName=gr_shiwu.YGName,---员工的名字
Idcard=gr_shiwu.IDcard,----员工的证件号码
yewu_name=qyyewuRen,---业务员
kefu_name=qykefuRen,--客服人员
workContent=isnull(cast(gr_shiwu.hukouType as varchar),'')+
',社保'+isnull(cast(gr_shiwu.Ex_str1 as varchar),'')
+',养老:'+
CASE WHEN gr_shiwu.Ex_int1 <> 2834 THEN 
'[样式开始]'+replace(isnull(cast(gr_shiwu.Ex_int1 as varchar),''),'.00','')+'[样式结束]'
ELSE
replace(isnull(cast(gr_shiwu.Ex_int1 as varchar),''),'.00','')
end
+',医疗:'+replace(isnull(cast(gr_shiwu.Ex_int2 as varchar),''),'.00','')
FROM [T_Lc_qiyework] AS wk
--V_Customer_geren_gerenExtended AS gr,
LEFT JOIN 
V_Customer_QiyeYuangongProduct AS gr_shiwu
ON wk.YGProNo=gr_shiwu.YGProNo
WHERE  --wk.yuangongId = gr.grNo  AND
  wk.workState = 0 AND DATEDIFF(m,wk.workStarDate,GETDATE())=0 AND wk.typeName='社保减员' AND wk.YGProNo=@gerenId
ELSE
--3无流程就插入
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
       '社保减员',GETDATE(),'初始化流程。'+CONVERT(varchar(100), GETDATE(), 120)+'[换行]',
       0,'系统',GETDATE(),
       0,0,0,0,
       GETDATE(),GETDATE(),
       qyyewuRen,GETDATE(),
       qykefuRen,GETDATE(),
isnull(cast(gr_shiwu.hukouType as varchar),'')+
',社保'+isnull(cast(gr_shiwu.Ex_str1 as varchar),'')
+',养老:'+
CASE WHEN gr_shiwu.Ex_int1 <> 2834 THEN 
'[样式开始]'+replace(isnull(cast(gr_shiwu.Ex_int1 as varchar),''),'.00','')+'[样式结束]'
ELSE
replace(isnull(cast(gr_shiwu.Ex_int1 as varchar),''),'.00','')
end
+',医疗:'+replace(isnull(cast(gr_shiwu.Ex_int2 as varchar),''),'.00','')
from --dbo.V_Customer_geren_gerenExtended AS gr , 
V_Customer_QiyeYuangongProduct AS gr_shiwu
WHERE
-- gr.grNo = gr_shiwu.grNo AND 
gr_shiwu.YGProNo = @gerenId 
END
-------三 执行取消，同步数据--------------------------------------------------------------------

IF	@UpdateType = '取消'
begin
--1取消增员 减员流程
UPDATE [dbo].[T_Lc_qiyework] SET workState = -1 ,workLog  = isnull(workLog+'[换行]','')+'系统取消流程！' +CONVERT(varchar(100), GETDATE(), 120) WHERE   YGProNo = @gerenId  and workstate=0 AND DATEDIFF(m,workStarDate,@dt)>=0
END
end

-------社保业务完成----




end


