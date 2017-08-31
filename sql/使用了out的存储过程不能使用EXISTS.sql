USE [etest_zongbu]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER      PROCEDURE [dbo].[proc_2017_geren_update_LC_shebao_shebaoyewu_new] 
@gerenId     VARCHAR(50), -- 编号
@workType    VARCHAR(50), -- 产品类型(社保产品，公积金产品，社保补缴....)
@UpdateType  VARCHAR(50), -- 产品类型（只有：增员 减员 取消）
@dt          DATETIME,   -- 流程处理月份
@Cur_grNo    VARCHAR(50)--个人 编号唯一
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


IF   (SELECT COUNT(*) FROM etest_zongbu.dbo.T_Lc_gerenwork_2017 WHERE workState = 0 AND DATEDIFF(m,@dt,workStarDate)<=0 AND typeName='社保增员' AND ProductID= @gerenId)>0
--2有流程就更新
--社保业务
BEGIN 

UPDATE etest_zongbu.dbo.T_Lc_gerenwork_2017 SET 
depname=gr_shiwu.depname,---产品所在部门
yuangongName=gr_shiwu.Name,--姓名
yuangongIdCard=gr_shiwu.IDcard,--身份证号
CompanyNo=gr_shiwu.CompanyNo,--隶属公司
qiyeName= qidu_gs.YijieCompanyName,--隶属公司
diqu= qidu_gs.yijie_qyarea,---地区
qiyeGuanxi= '是',---隶属关系是
qiyeGuanxi_name=qidu_gs.YijieCompanyName,--隶属关系 
workContent=isnull(cast(gr_shiwu.hukouType as varchar),'')+
',社保'+isnull(cast(gr_shiwu.Ex_str1 as varchar),'')
+',养老:'+
CASE WHEN gr_shiwu.Ex_int1 <> 3082 THEN 
'[样式开始]'+replace(isnull(cast(gr_shiwu.Ex_int1 as varchar),''),'.00','')+'[样式结束]'
ELSE
replace(isnull(cast(gr_shiwu.Ex_int1 as varchar),''),'.00','')
end
+',医疗:'+replace(isnull(cast(gr_shiwu.Ex_int2 as varchar),''),'.00','')

FROM etest_zongbu.dbo.T_Lc_gerenwork_2017 AS wk
LEFT JOIN 
etest_zongbu..V_Customer_geren_gerenExtended_GerenProduct_Curr AS gr_shiwu
ON wk.ProductID=gr_shiwu.grProNo
 LEFT JOIN etest_zongbu..Base_YijieCompany AS qidu_gs
ON gr_shiwu.CompanyNo=qidu_gs.YijieCompanyCode
WHERE  
  wk.workState = 0 AND DATEDIFF(m,wk.workStarDate,GETDATE())=0 AND wk.typeName='社保增员' AND wk.ProductID=@gerenId
 END 
ELSE
BEGIN 
--PRINT @gerenId
--RETURN 
--PRINT '5555555'
--RETURN 1
--3无流程就插入
---生成唯一编号
DECLARE @var VARCHAR(50) ;
exec etest_zongbu.dbo.Pr_Base_GetNewNo @var OUTPUT,'grrz'
insert  INTO etest_zongbu.dbo.T_Lc_gerenwork_2017 
        (
        is_zj_leixing,----增减员类型（增员1 减员2）
        rz_no,---日志唯一编号
        Cur_Operation_Step,---当前操作步骤（STEP1000，。。。）
        Cur_Operation_M_Flag,--当前步骤金额验证  int 
        Cur_Operation_name,
       -- Cur_Operation_Stardate,---当前步骤开始时间
        TypeNo,--日志分类标志 （TYPE000，TYPE001。。）
        yewu_M_Flag,--业务员 是否需要 金钱验证
        kefu_M_Flag,---客服 是否需要 金钱验证
        shenhe_M_Flag,---审核人 是否需要钱的
        shiwu_zhuanyuan_M_Flag,--事务专员 是否需要钱的
        shiwu_zhuli_M_Flag,--事务助理 是否需要钱的
        yewu_jingli_M_Flag,---客服经理 是否需要钱
         adddate,--日志生成时间
         
        CompanyNo,depname ,qiyeId ,qiyeName ,diqu ,qiyeGuanxi ,qiyeGuanxi_name ,yuangongId ,yuangongName ,yuangongIdCard ,ProductID ,
        typeName ,workInitDate  ,workLog ,
       -- last_Operation_Step ,last_Operation_name ,last_Operation_date ,Ex_flag , fh_flag ,
        M_zidong_flag ,M_qiangzhi_flag ,workState ,workStarDate ,workExecDate,workContent)
SELECT 
1,
@var,
'STEP1000',
0,
gr_shiwu.yewuName,----更新为业务员的名字
--GETDATE(),
'TYPE001',
0,
0,
0,
1,
1,
1,
GETDATE(),

gr_shiwu.CompanyNo,gr_shiwu.DepName,0,qidu_gs.YijieCompanyName,qidu_gs.yijie_qyarea,'是',qidu_gs.YijieCompanyName,gr_shiwu.grNo,gr_shiwu.name,gr_shiwu.IDcard,@gerenId ,
       '社保增员',GETDATE(),'初始化流程。'+CONVERT(varchar(100), GETDATE(), 120)+'[换行]',
     --  0,'系统',GETDATE(),NULL,0,
       0,0,0,GETDATE(),GETDATE(),
isnull(cast(gr_shiwu.hukouType as varchar),'')+
',社保'+isnull(cast(gr_shiwu.Ex_str1 as varchar),'')
+',养老:'+
CASE WHEN gr_shiwu.Ex_int1 <> 3082 THEN 
'[样式开始]'+replace(isnull(cast(gr_shiwu.Ex_int1 as varchar),''),'.00','')+'[样式结束]'
ELSE
replace(isnull(cast(gr_shiwu.Ex_int1 as varchar),''),'.00','')
end
+',医疗:'+replace(isnull(cast(gr_shiwu.Ex_int2 as varchar),''),'.00','')
from 
etest_zongbu..V_Customer_geren_gerenExtended_GerenProduct_Curr AS gr_shiwu
LEFT JOIN etest_zongbu..Base_YijieCompany AS qidu_gs
ON 
gr_shiwu.CompanyNo=qidu_gs.YijieCompanyCode
WHERE
gr_shiwu.grProNo = @gerenId 
END 

END

-------二 执行减员，同步数据--------------------------------------------------------------------
IF	@UpdateType = '减员'
begin

IF (SELECT COUNT(*) FROM etest_zongbu.dbo.T_Lc_gerenwork_2017 WHERE workState = 0 AND DATEDIFF(m,@dt,workStarDate)<=0 AND typeName='社保减员' AND ProductID= @gerenId)>0
BEGIN 
--2有流程就更新
UPDATE etest_zongbu.dbo.T_Lc_gerenwork_2017 SET
 yuangongName=gr_shiwu.name,
 yuangongIdCard=gr_shiwu.IDcard,
CompanyNo=gr_shiwu.CompanyNo,
qiyeName= qidu_gs.YijieCompanyName,
diqu= qidu_gs.yijie_qyarea,
qiyeGuanxi= '是',
qiyeGuanxi_name=qidu_gs.YijieCompanyName, 
workContent=isnull(cast(gr_shiwu.hukouType as varchar),'')+
',社保'+isnull(cast(gr_shiwu.Ex_str1 as varchar),'')
+',养老:'+
CASE WHEN gr_shiwu.Ex_int1 <> 3082 THEN 
'[样式开始]'+replace(isnull(cast(gr_shiwu.Ex_int1 as varchar),''),'.00','')+'[样式结束]'
ELSE
replace(isnull(cast(gr_shiwu.Ex_int1 as varchar),''),'.00','')
end
+',医疗:'+replace(isnull(cast(gr_shiwu.Ex_int2 as varchar),''),'.00','')
FROM etest_zongbu.dbo.T_Lc_gerenwork_2017 AS wk
LEFT JOIN 
etest_zongbu..V_Customer_geren_gerenExtended_GerenProduct_Curr AS gr_shiwu
ON wk.ProductID=gr_shiwu.grProNo
LEFT JOIN etest_zongbu..Base_YijieCompany AS qidu_gs
ON 
gr_shiwu.CompanyNo=qidu_gs.YijieCompanyCode
WHERE  
  wk.workState = 0 AND DATEDIFF(m,wk.workStarDate,GETDATE())=0 AND wk.typeName='社保减员' AND wk.ProductID=@gerenId
  END 
ELSE
BEGIN
--3无流程就插入
---生成唯一编号
--SELECT * FROM  etest_zongbu.dbo.T_base_ControlNewNo 
DECLARE @var1 VARCHAR(50) ;
exec etest_zongbu.dbo.Pr_Base_GetNewNo @var1 OUTPUT,'grrz'
insert  INTO etest_zongbu.dbo.T_Lc_gerenwork_2017 
        (  is_zj_leixing,----增减员类型（增员1 减员2）
         rz_no,---日志唯一编号
        Cur_Operation_Step,---当前操作步骤（STEP1000，。。。）
        Cur_Operation_M_Flag,--当前步骤金额验证  int 
        Cur_Operation_name,
      --  Cur_Operation_Stardate,---当前步骤开始时间
        TypeNo,--日志分类标志 （TYPE000，TYPE001。。）
        yewu_M_Flag,--业务员 是否需要 金钱验证
        kefu_M_Flag,---客服 是否需要 金钱验证
        shenhe_M_Flag,---审核人 是否需要钱的
        shiwu_zhuanyuan_M_Flag,--事务专员 是否需要钱的
        shiwu_zhuli_M_Flag,--事务助理 是否需要钱的
        yewu_jingli_M_Flag,---客服经理 是否需要钱
        adddate,--日志生成时间
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

gr_shiwu.CompanyNo,gr_shiwu.DepName,0,qidu_gs.YijieCompanyName,qidu_gs.yijie_qyarea,'是',qidu_gs.YijieCompanyName,gr_shiwu.grNo,gr_shiwu.name,gr_shiwu.IDcard,@gerenId ,
'社保减员',GETDATE(),'初始化流程。'+CONVERT(varchar(100), GETDATE(), 120)+'[换行]',
--- 0,'系统',GETDATE(),NULL,0,
 0,0,0,GETDATE(),GETDATE(),
isnull(cast(gr_shiwu.hukouType as varchar),'')+
',社保'+isnull(cast(gr_shiwu.Ex_str1 as varchar),'')
+',养老:'+
CASE WHEN gr_shiwu.Ex_int1 <> 3082 THEN 
'[样式开始]'+replace(isnull(cast(gr_shiwu.Ex_int1 as varchar),''),'.00','')+'[样式结束]'
ELSE
replace(isnull(cast(gr_shiwu.Ex_int1 as varchar),''),'.00','')
end
+',医疗:'+replace(isnull(cast(gr_shiwu.Ex_int2 as varchar),''),'.00','')
from 
 etest_zongbu..V_Customer_geren_gerenExtended_GerenProduct_Curr AS gr_shiwu
 LEFT JOIN etest_zongbu..Base_YijieCompany AS qidu_gs
ON 
gr_shiwu.CompanyNo=qidu_gs.YijieCompanyCode
WHERE 
gr_shiwu.grProNo = @gerenId 
END 

END
-------三 执行取消，同步数据--------------------------------------------------------------------

IF	@UpdateType = '取消'
BEGIN

------------------------------------------------------插入日志----开始---------------------------------------------
DECLARE @typename VARCHAR(50)
DECLARE @rz_no VARCHAR(50)--流程表里面的唯一编号
DECLARE @Cur_count INT--数量
DECLARE @star_date DATETIME
DECLARE @Cur_dt DATETIME
SET @Cur_dt = GETDATE()  
 -----------得到流程唯一编号---
 SELECT
  rz_no ,---流程表里面的唯一编号
  typename--日志类型
 INTO #temp_geren
 FROM 
 etest_zongbu.dbo.T_Lc_gerenwork_2017 WHERE 
  ProductID = @gerenId  and workstate=0 AND DATEDIFF(m,@dt,workStarDate)<=0
 AND TypeNo<>'TYPE009'---不会取消转下月办理的
 
 SELECT TOP 1 @rz_no=rz_no,@typename=typename
 from #temp_geren
 WHERE 1=1  
 ORDER BY rz_no ASC

 SELECT @Cur_count=COUNT(*) from #temp_geren 
-------------------开始循环
WHILE @Cur_count > 0 
BEGIN

IF (SELECT COUNT(*) FROM etest_zongbu..T_lc_gerenwork_log_2017 WHERE rz_no=@rz_no)>0
BEGIN 

---得到上一条日志办理时间 
SELECT @star_date=MAX(caozuo_date) FROM etest_zongbu..T_lc_gerenwork_log_2017 WHERE rz_no=@rz_no
---日志表里面插入数据
INSERT INTO etest_zongbu..T_lc_gerenwork_log_2017
(typename,rz_no,caozuo_name,caozuo_date,star_date,step_no,button_no,is_kehu_flag,is_yewu_flag,is_jixiao_flag,adddate,worktxt)
SELECT typename,rz_no,'系统',@Cur_dt,@star_date,Cur_Operation_Step,'BUTTON1000',1,1,0,@Cur_dt,
(SELECT replace(geren_beizhu,'[业务名称]',@typename)  FROM etest_zongbu..T_lc_gerenwork_button_2017 WHERE button_no='BUTTON1000' AND  is_geren=1)
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
-------------------循环结束
DROP TABLE #temp_geren

------------------------------------------------------插入日志----结束---------------------------------------------

--1取消增员 减员流程
UPDATE etest_zongbu.dbo.T_Lc_gerenwork_2017 SET workState = -1 ,workLog  = isnull(workLog+'[换行]','')+'系统取消流程！' +CONVERT(varchar(100), GETDATE(), 120)
 WHERE
 ProductID = @gerenId  and workstate=0 AND DATEDIFF(m,@dt,workStarDate)<=0
 AND TypeNo<>'TYPE009'---不会取消转下月办理的
 ----
 
 
END



END

-------完成----

---------------------------------------------------------------------更新人-------------------
---1.客服经理 
UPDATE etest_zongbu.dbo.[T_Lc_gerenwork_2017] SET yewu_jingli_name='卞敬' WHERE workstate = 0 AND typename IN ('社保增员','社保减员') AND ISNULL(yewu_jingli_name,'')=''
---2.业务人员
update etest_zongbu.dbo.[T_Lc_gerenwork_2017]  set yewu_name =a.yewuName from etest_zongbu..V_Customer_geren_gerenExtended_GerenProduct_Curr AS a
where a.grProNo = productid and  isnull(yewu_name,'') <> a.yewuName  and   workstate = 0 and a.ActFalg=1
AND typename IN ('社保增员') 
--3.客服人员
update etest_zongbu.dbo.[T_Lc_gerenwork_2017]  set kefu_name =a.kefuName from etest_zongbu..V_Customer_geren_gerenExtended_GerenProduct_Curr AS a  
where a.grProNo = productid and  isnull(kefu_name,'') <> a.kefuName and   workstate = 0 and a.ActFalg=1
AND typename IN ('社保增员','社保减员') 
--4.事务助理
update  etest_zongbu.dbo.[T_Lc_gerenwork_2017]  set shiwu_zhuli_name = etest_zongbu..com_diqu.name 
from etest_zongbu..com_diqu where  workstate = 0 AND  ISNULL(shiwu_zhuli_name,'') <> etest_zongbu..com_diqu.name
 AND   etest_zongbu..com_diqu.diqu = etest_zongbu.dbo.[T_Lc_gerenwork_2017].diqu
AND typename IN ('社保增员','社保减员') 

END

 

GO
