USE [etest_zongbu]
GO
 Object  StoredProcedure [dbo].[Pr_Money_qiye]    Script Date 03062017 142445 
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

---原来的表   T_Money_qiye
---为了测试新建的表 T_Money_qiye

--  select M_fwf_Zhongjie, from  etest_zongbu..T_Money_qiye where prono='prono_dbyw' and M_fwf_Zhongjie0
--   update etest_zongbu..T_Money_qiye  set M_fwf_Zhongjie=0 where proname='人事服务' and M_fwf_Zhongjie0
--delete etest_zongbu..T_Money_qiye 

---测试 执行 存储过程 exec  [dbo].[Pr_Money_qiye_测试]  '2016-11-30'

ALTER        PROCEDURE [dbo].[Pr_Money_qiye] 
   @dt     datetime

AS
BEGIN 

if @dt='' or @dt =null
begin
delete from etest_zongbu..T_Money_qiye WHERE DATEDIFF(m,'2016-10-10',koufeiDate)0---为了不破坏历史数据
insert into etest_zongbu..T_Money_qiye
(
ht_stardate  ,--合同开始时间
ht_enddate  ,  -- 合同结束时间
qyguanxi , ---企业 隶属关系

qyfuzeRen,DepName,
fwstardate,fwenddate,
M_fwf_Zhongjie,M_djf_Zhongjie,
Mtotal_yue_EndMonth,Mtotal_yue_Curr,
yewuName,yewudate,kefuName,QyNo,QyName,
fwf,dif,ProNo,proname,
ProYuanGong_koufeiType,guanxi_ycx,context,koufeiDate)
--=======事务的流水
----情况4 所有产品计算的代缴费  服务费(不包括打包产品的服务费)
select 
MAX(ht_stardate) AS ht_stardate  ,--合同开始时间
MAX(ht_enddate) AS ht_enddate ,  -- 合同结束时间
MAX(qyguanxi) AS qyguanxi , ---企业 隶属关系

MAX(qyfuzeRen)AS qyfuzeRen,--企业负责人
max(DepName) as DepName ,--企业 分部
max(fwstardate) as  fwstardate,
max(fwenddate)  as fwenddate,
SUM(isnull(M_fwf_Zhongjie,0)) as M_fwf_Zhongjie,--中介服务费
SUM(isnull(M_djf_Zhongjie,0)) as M_djf_Zhongjie ,--中介代缴费
0 as yue_yuedi,--月底余额
0 as yue,--当前余额
max(yewuName)  as yewuName,--业务员
max(yewudate) as yewudate,--业务提成时间
max(kefuName) as  kefuName,--客服人员（企业的）
QyNo,--企业编号
max(QyName) as QyName,--企业名称
--CASE WHEN MAX(is_dabaoyewu)='是' THEN  0 ELSE SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita) END as fwf,--服务费
CASE WHEN MAX(ProYuanGong_koufeiType)=1 THEN
CASE WHEN MAX(is_dabaoyewu)='是' THEN 0 ELSE  SUM(a.M_fwf_Biaozhun-a.M_fwf_Youhui) END 
WHEN  MAX(ProYuanGong_koufeiType)=2 THEN  
CASE WHEN MAX(is_dabaoyewu)='是' THEN 0 ELSE  SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita) END
ELSE 
0
END as fwf, --服务费


SUM(a.M_djf_Biaozhun) as dif,---代缴费
ProNo,--产品编号
MAX(proname) as proname,--产品名称
MAX(ProYuanGong_koufeiType) as ProYuanGong_koufeiType,--员工扣费类型
MAX(guanxi_ycx) as guanxi_ycx,--是否为一次性客户

'服务费'+replace(isnull(cast(SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita) as varchar),''),'.000000','')+'，'
 +max(ProName)+'代缴费'+replace(isnull(cast(SUM(a.M_djf_Biaozhun) as varchar),''),'.000000','')+'。'  as context,---备注信息

 CASE WHEN MAX(is_dabaoyewu)='是' AND SUM(a.M_djf_Biaozhun)0 THEN  max(a.ProName)+'代缴费'+replace(isnull(cast(SUM(a.M_djf_Biaozhun) as varchar),''),'.000000','') 
WHEN   MAX(is_dabaoyewu)='否' AND SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita)0 AND SUM(a.M_djf_Biaozhun)=0 THEN '服务费'+replace(isnull(cast( SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita)  as varchar),''),'.000000','')--+';'
WHEN MAX(is_dabaoyewu)='否' AND SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita)=0 AND SUM(a.M_djf_Biaozhun)0 THEN max(ProName)+'代缴费'+replace(isnull(cast(SUM(a.M_djf_Biaozhun) as varchar),''),'.000000','') 
WHEN MAX(is_dabaoyewu)='否' AND SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita)0 AND SUM(a.M_djf_Biaozhun)0 THEN '服务费'+replace(isnull(cast( SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita)  as varchar),''),'.000000','')+';'+max(ProName)+'代缴费'+replace(isnull(cast(SUM(a.M_djf_Biaozhun) as varchar),''),'.000000','') 
ELSE ''
END 
as context,---备注信息
 
 CASE WHEN MAX(ProYuanGong_koufeiType)=1 THEN 
CASE WHEN MAX(is_dabaoyewu)='是' AND SUM(a.M_djf_Biaozhun)0 THEN  max(ProName)+'代缴费'+replace(isnull(cast(SUM(a.M_djf_Biaozhun) as varchar),''),'.000000','') 
WHEN   MAX(is_dabaoyewu)='否' AND SUM(a.M_fwf_Biaozhun-a.M_fwf_Youhui)0 AND SUM(a.M_djf_Biaozhun)=0 THEN '服务费'+replace(isnull(cast( SUM(a.M_fwf_Biaozhun-a.M_fwf_Youhui)  as varchar),''),'.000000','')--+';'
WHEN MAX(is_dabaoyewu)='否' AND SUM(a.M_fwf_Biaozhun-a.M_fwf_Youhui)=0 AND SUM(a.M_djf_Biaozhun)0 THEN max(ProName)+'代缴费'+replace(isnull(cast(SUM(a.M_djf_Biaozhun) as varchar),''),'.000000','') 
WHEN MAX(is_dabaoyewu)='否' AND SUM(a.M_fwf_Biaozhun-a.M_fwf_Youhui)0 AND SUM(a.M_djf_Biaozhun)0 THEN '服务费'+replace(isnull(cast( SUM(a.M_fwf_Biaozhun-a.M_fwf_Youhui)  as varchar),''),'.000000','')+';'+max(ProName)+'代缴费'+replace(isnull(cast(SUM(a.M_djf_Biaozhun) as varchar),''),'.000000','') 
ELSE ''
END 
WHEN  MAX(ProYuanGong_koufeiType)=2 THEN  
CASE WHEN MAX(is_dabaoyewu)='是' AND SUM(a.M_djf_Biaozhun)0 THEN  max(ProName)+'代缴费'+replace(isnull(cast(SUM(a.M_djf_Biaozhun) as varchar),''),'.000000','') 
WHEN   MAX(is_dabaoyewu)='否' AND SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita)0 AND SUM(a.M_djf_Biaozhun)=0 THEN '服务费'+replace(isnull(cast( SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita)  as varchar),''),'.000000','')--+';'
WHEN MAX(is_dabaoyewu)='否' AND SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita)=0 AND SUM(a.M_djf_Biaozhun)0 THEN max(ProName)+'代缴费'+replace(isnull(cast(SUM(a.M_djf_Biaozhun) as varchar),''),'.000000','') 
WHEN MAX(is_dabaoyewu)='否' AND SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita)0 AND SUM(a.M_djf_Biaozhun)0 THEN '服务费'+replace(isnull(cast( SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita)  as varchar),''),'.000000','')+';'+max(ProName)+'代缴费'+replace(isnull(cast(SUM(a.M_djf_Biaozhun) as varchar),''),'.000000','') 
ELSE ''
END 
ELSE 
''
END
 as context,---备注信息
 
 max(a.koufeiDate)  as koufeiDate--扣费时间
 from 
etest_zongbu..t_Money_YuanGongProduct as a
where --ProYuanGong_koufeiType=2 --and ---特殊服务费
1=1
AND  DATEDIFF(M,'2016-10-10',koufeiDate)0---为了不破坏历史数据
group by datediff(m,koufeiDate,GETDATE()),QyNo,ProNo
union ALL
----------=================================================================================================================================---------------------------------
----情况3所有打包产品 以企业为单位    计算的服务费
select 
MAX(ht_stardate) AS ht_stardate  ,--合同开始时间
MAX(ht_enddate) AS ht_enddate ,  -- 合同结束时间
MAX(qyguanxi) AS qyguanxi , ---企业 隶属关系

MAX(qyfuzeRen) AS qyfuzeRen,--企业 负责人
max(DepName) as DepName ,--企业 分部
max(fwstardate) as  fwstardate,
max(fwenddate)  as fwenddate,
0 as M_fwf_Zhongjie,--中介服务费
0 as M_djf_Zhongjie ,--中介代缴费
0 as yue_yuedi,--月底余额
0 as yue,--当前余额
max(yewuName)  as yewuName,--业务员
max(yewudate) as yewudate,--业务提成时间
max(kefuName) as  kefuName,--客服人员（企业的）
QyNo,--企业编号
max(QyName) as QyName,--企业名称
dbo.Getmax(
(select sum(yuangong_all) from 
(
select dbo.Getmax(max(M_fwf_yuangongZuidi),
 --SUM(CASE WHEN is_dabaoyewu ='是' THEN  M_fwf_Biaozhun-M_fwf_Youhui ELSE 0 END )
  SUM(
 CASE
  WHEN is_dabaoyewu='是' AND ProYuanGong_koufeiType=1  THEN  M_fwf_Biaozhun-M_fwf_Youhui
  WHEN is_dabaoyewu='是' AND ProYuanGong_koufeiType=2  THEN  M_fwf_Biaozhun_Qita-M_fwf_Youhui_Qita
  ELSE 0 
 END)
 
 ) as yuangong_all
 from etest_zongbu..t_Money_YuanGongProduct as b
where --ProYuanGong_koufeiType=1 AND
 QyNo=a.QyNo 
and DATEDIFF(m,max(a.koufeiDate),b.koufeiDate)=0
group by YGNo
) as cc
)
, max(a.M_fwf_qiyezuidi)
) as fwf ,
--服务费
0 as dif,--代缴费
 'prono_dbyw' as ProNo,--产品编号
'人事服务' as proname ,--产品名称
1 as ProYuanGong_koufeiType,--员工扣费类型
MAX(guanxi_ycx) as guanxi_ycx,--是否为一次性客户
'人事服务费'+
cast(
dbo.Getmax(
(select sum(yuangong_all) from 
(
select dbo.Getmax(max(M_fwf_yuangongZuidi),
 --SUM(CASE WHEN is_dabaoyewu ='是' THEN  M_fwf_Biaozhun-M_fwf_Youhui ELSE 0 END)
  SUM(
 CASE
  WHEN is_dabaoyewu='是' AND ProYuanGong_koufeiType=1  THEN  M_fwf_Biaozhun-M_fwf_Youhui
  WHEN is_dabaoyewu='是' AND ProYuanGong_koufeiType=2  THEN  M_fwf_Biaozhun_Qita-M_fwf_Youhui_Qita
  ELSE 0 
 END)
 ) as yuangong_all
 from etest_zongbu..t_Money_YuanGongProduct as b
where 
QyNo=a.QyNo 
and DATEDIFF(m,max(a.koufeiDate),b.koufeiDate)=0
group by YGNo
) as cc
 )
 , max(a.M_fwf_qiyezuidi)
 )
 as varchar)----服务费
 AS context --备注信息 
,max(a.koufeiDate) as koufeiDate--扣费时间
 from 
etest_zongbu..t_Money_YuanGongProduct as a
where 1=1  
AND  DATEDIFF(M,'2016-10-10',koufeiDate)0---为了不破坏历史数据
AND  is_dabaoyewu ='是'--所有打包产品
group by datediff(m,a.koufeiDate,GETDATE()),QyNo--,ProNo
-------------------------====================================================================----------------------------------------------
UNION ALL
-------------情况1没有产品的企业(收个最低服务费  原来叫做企业产品 现在叫人事服务 代缴费0 )
select 
MAX(ht_stardate) AS ht_stardate  ,--合同开始时间
MAX(ht_enddate) AS ht_enddate ,  -- 合同结束时间
MAX(qyguanxi) AS qyguanxi , ---企业 隶属关系

MAX(qyfuzeRen) AS qyfuzeRen,--企业 负责人
max(DepName) as DepName ,--企业 分部
max(fwstardate) as  fwstardate,
max(fwenddate)  as fwenddate,
0 as M_fwf_Zhongjie,--中介服务费
0 as M_djf_Zhongjie ,--中介代缴费
0 as yue_yuedi,--月底余额
0 as yue,--当前余额
max(yewuName)  as yewuName,--业务员
max(yewudate) as yewudate,--业务提成时间
max(kefuName) as  kefuName,--客服人员（企业的）
QyNo,--企业编号
max(QyName) as QyName,--企业名称
max(a.M_fwf_qiyezuidi) as fwf ,--服务费
0 as dif,--代缴费
 'prono_dbyw' as ProNo,--产品编号
'人事服务' as proname ,--产品名称
1 as ProYuanGong_koufeiType,--员工扣费类型
MAX(guanxi_ycx) as guanxi_ycx,--是否为一次性客户
'人事服务费'+
cast(max(a.M_fwf_qiyezuidi) as varchar)----服务费
 AS context ,--备注信息 
max(a.koufeiDate) as koufeiDate--扣费时间
 from 
etest_zongbu..t_Money_YuanGongProduct as a
where 1=1  
AND  DATEDIFF(M,'2016-10-10',koufeiDate)0---为了不破坏历史数据
 AND a.ProNo IS NULL --说明是没有产品的  企业
group by datediff(m,a.koufeiDate,GETDATE()),QyNo--,ProNo

UNION ALL
-----------情况2没有打包产品 但是有产品的企业 收个最低服务费
SELECT 
MAX(ht_stardate) AS ht_stardate  ,--合同开始时间
MAX(ht_enddate) AS ht_enddate ,  -- 合同结束时间
MAX(qyguanxi) AS qyguanxi , ---企业 隶属关系

MAX(qyfuzeRen) AS qyfuzeRen,--企业 负责人
max(DepName) as DepName ,--企业 分部
max(fwstardate) as  fwstardate,
max(fwenddate)  as fwenddate,
0 as M_fwf_Zhongjie,--中介服务费
0 as M_djf_Zhongjie ,--中介代缴费
0 as yue_yuedi,--月底余额
0 as yue,--当前余额
max(yewuName)  as yewuName,--业务员
max(yewudate) as yewudate,--业务提成时间
max(kefuName) as  kefuName,--客服人员（企业的）
QyNo,--企业编号
max(QyName) as QyName,--企业名称
MAX(M_fwf_qiyezuidi) as fwf,--服务费
0 as dif,--代缴费
 'prono_dbyw' as ProNo,--产品编号
'人事服务' as proname ,--产品名称
1 as ProYuanGong_koufeiType,--员工扣费类型
MAX(guanxi_ycx) as guanxi_ycx,--是否为一次性客户
'人事服务费'+cast( MAX(M_fwf_qiyezuidi) as varchar) AS context --备注信息 ,
,max(koufeiDate) as koufeiDate--扣费时间
FROM etest_zongbu..t_Money_YuanGongProduct AS a
WHERE 1=1 AND    ProNo IS NOT NULL--说明有产品 
AND  DATEDIFF(M,'2016-10-10',koufeiDate)0---为了不破坏历史数据
GROUP BY  DATEDIFF(M,GETDATE(),koufeiDate),QYNo
--ORDER BY  MAX(koufeiDate)
HAVING a.qyno   --说明没有打包产品
NOT IN
(
SELECT qyno FROM etest_zongbu..t_Money_YuanGongProduct 
WHERE 1=1 AND    
 is_dabaoyewu ='是'
AND   DATEDIFF(M,koufeiDate,MAX(a.koufeiDate))=0
)
ORDER BY  MAX(a.koufeiDate)
----------=================================================================结束================================================================---------------------------------
----------=======================================================删掉费用为0的===========================================================================---------------------------------

DELETE etest_zongbu..T_Money_qiye WHERE fwf+dif =0 AND  DATEDIFF(M,'2016-10-10',koufeiDate)0---为了不破坏历史数据
END
----------=================================================================================================================================---------------------------------
if @dt'' and @dtnull
begin
delete from etest_zongbu..T_Money_qiye where DATEDIFF(M,@dt,koufeiDate)=0 AND  DATEDIFF(M,'2016-10-10',koufeiDate)0
insert into etest_zongbu..T_Money_qiye
(
ht_stardate  ,--合同开始时间
 ht_enddate ,  -- 合同结束时间
 qyguanxi , ---企业 隶属关系
qyfuzeRen,DepName,fwstardate,fwenddate,
M_fwf_Zhongjie,M_djf_Zhongjie,Mtotal_yue_EndMonth,Mtotal_yue_Curr,
yewuName,yewudate,kefuName,QyNo,QyName,fwf,dif,ProNo,proname,ProYuanGong_koufeiType,guanxi_ycx,context,koufeiDate)
--=======事务的流水
----情况4 所有产品计算的代缴费  服务费(不包括打包产品的服务费)
select 
MAX(ht_stardate) AS ht_stardate  ,--合同开始时间
MAX(ht_enddate) AS ht_enddate ,  -- 合同结束时间
MAX(qyguanxi) AS qyguanxi , ---企业 隶属关系

MAX(qyfuzeRen) AS qyfuzeRen,--企业负责人
max(DepName) as DepName ,--企业 分部
max(fwstardate) as  fwstardate,
max(fwenddate)  as fwenddate,
SUM(isnull(M_fwf_Zhongjie,0)) as M_fwf_Zhongjie,--中介服务费
SUM(isnull(M_djf_Zhongjie,0)) as M_djf_Zhongjie ,--中介代缴费
0 as yue_yuedi,--月底余额
0 as yue,--当前余额
max(yewuName)  as yewuName,--业务员
max(yewudate) as yewudate,--业务提成时间
max(kefuName) as  kefuName,--客服人员（企业的）
QyNo,--企业编号
max(QyName) as QyName,--企业名称
--CASE WHEN MAX(is_dabaoyewu)='是' THEN 0 ELSE  SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita) END as fwf,--服务费


CASE WHEN MAX(ProYuanGong_koufeiType)=1 THEN
CASE WHEN MAX(is_dabaoyewu)='是' THEN 0 ELSE  SUM(a.M_fwf_Biaozhun-a.M_fwf_Youhui) END 
WHEN  MAX(ProYuanGong_koufeiType)=2 THEN  
CASE WHEN MAX(is_dabaoyewu)='是' THEN 0 ELSE  SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita) END
ELSE 
0
END as fwf, --服务费

SUM(a.M_djf_Biaozhun) as dif,---代缴费
ProNo,--产品编号
MAX(proname) as proname,--产品名称
MAX(ProYuanGong_koufeiType) as ProYuanGong_koufeiType,--员工扣费类型
MAX(guanxi_ycx) as guanxi_ycx,--是否为一次性客户

'服务费'+replace(isnull(cast(SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita) as varchar),''),'.000000','')+'，'
 +max(ProName)+'代缴费'+replace(isnull(cast(SUM(a.M_djf_Biaozhun) as varchar),''),'.000000','')+'。' 
 
CASE WHEN MAX(is_dabaoyewu)='是' AND SUM(a.M_djf_Biaozhun)0 THEN  max(a.ProName)+'代缴费'+replace(isnull(cast(SUM(a.M_djf_Biaozhun) as varchar),''),'.000000','') 
WHEN   MAX(is_dabaoyewu)='否' AND SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita)0 AND SUM(a.M_djf_Biaozhun)=0 THEN '服务费'+replace(isnull(cast( SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita)  as varchar),''),'.000000','')--+';'
WHEN MAX(is_dabaoyewu)='否' AND SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita)=0 AND SUM(a.M_djf_Biaozhun)0 THEN max(ProName)+'代缴费'+replace(isnull(cast(SUM(a.M_djf_Biaozhun) as varchar),''),'.000000','') 
WHEN MAX(is_dabaoyewu)='否' AND SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita)0 AND SUM(a.M_djf_Biaozhun)0 THEN '服务费'+replace(isnull(cast( SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita)  as varchar),''),'.000000','')+';'+max(ProName)+'代缴费'+replace(isnull(cast(SUM(a.M_djf_Biaozhun) as varchar),''),'.000000','') 
ELSE ''
END 
as context,---备注信息


CASE WHEN MAX(ProYuanGong_koufeiType)=1 THEN 
CASE WHEN MAX(is_dabaoyewu)='是' AND SUM(a.M_djf_Biaozhun)0 THEN  max(ProName)+'代缴费'+replace(isnull(cast(SUM(a.M_djf_Biaozhun) as varchar),''),'.000000','') 
WHEN   MAX(is_dabaoyewu)='否' AND SUM(a.M_fwf_Biaozhun-a.M_fwf_Youhui)0 AND SUM(a.M_djf_Biaozhun)=0 THEN '服务费'+replace(isnull(cast( SUM(a.M_fwf_Biaozhun-a.M_fwf_Youhui)  as varchar),''),'.000000','')--+';'
WHEN MAX(is_dabaoyewu)='否' AND SUM(a.M_fwf_Biaozhun-a.M_fwf_Youhui)=0 AND SUM(a.M_djf_Biaozhun)0 THEN max(ProName)+'代缴费'+replace(isnull(cast(SUM(a.M_djf_Biaozhun) as varchar),''),'.000000','') 
WHEN MAX(is_dabaoyewu)='否' AND SUM(a.M_fwf_Biaozhun-a.M_fwf_Youhui)0 AND SUM(a.M_djf_Biaozhun)0 THEN '服务费'+replace(isnull(cast( SUM(a.M_fwf_Biaozhun-a.M_fwf_Youhui)  as varchar),''),'.000000','')+';'+max(ProName)+'代缴费'+replace(isnull(cast(SUM(a.M_djf_Biaozhun) as varchar),''),'.000000','') 
ELSE ''
END 
WHEN  MAX(ProYuanGong_koufeiType)=2 THEN  
CASE WHEN MAX(is_dabaoyewu)='是' AND SUM(a.M_djf_Biaozhun)0 THEN  max(ProName)+'代缴费'+replace(isnull(cast(SUM(a.M_djf_Biaozhun) as varchar),''),'.000000','') 
WHEN   MAX(is_dabaoyewu)='否' AND SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita)0 AND SUM(a.M_djf_Biaozhun)=0 THEN '服务费'+replace(isnull(cast( SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita)  as varchar),''),'.000000','')--+';'
WHEN MAX(is_dabaoyewu)='否' AND SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita)=0 AND SUM(a.M_djf_Biaozhun)0 THEN max(ProName)+'代缴费'+replace(isnull(cast(SUM(a.M_djf_Biaozhun) as varchar),''),'.000000','') 
WHEN MAX(is_dabaoyewu)='否' AND SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita)0 AND SUM(a.M_djf_Biaozhun)0 THEN '服务费'+replace(isnull(cast( SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita)  as varchar),''),'.000000','')+';'+max(ProName)+'代缴费'+replace(isnull(cast(SUM(a.M_djf_Biaozhun) as varchar),''),'.000000','') 
ELSE ''
END 
ELSE 
''
END
 as context,---备注信息




 
 max(a.koufeiDate)  as koufeiDate--扣费时间
 from 
etest_zongbu..t_Money_YuanGongProduct as a
where --ProYuanGong_koufeiType=2 --and ---特殊服务费
 DATEDIFF(M,'2016-10-10',koufeiDate)0--- 为了不破坏老的数据
and DATEDIFF(M,@dt,koufeiDate)=0
group by datediff(m,koufeiDate,GETDATE()),QyNo,ProNo
union ALL
----------=================================================================================================================================---------------------------------
----------------------------------情况3所有打包产品 以企业为单位    计算的服务费
select 
MAX(ht_stardate) AS ht_stardate  ,--合同开始时间
MAX(ht_enddate) AS ht_enddate ,  -- 合同结束时间
MAX(qyguanxi) AS qyguanxi , ---企业 隶属关系

MAX(qyfuzeRen) AS qyfuzeRen,--企业 负责人
max(DepName) as DepName ,--企业 分部
max(fwstardate) as  fwstardate,
max(fwenddate)  as fwenddate,
0 as M_fwf_Zhongjie,--中介服务费
0 as M_djf_Zhongjie ,--中介代缴费
0 as yue_yuedi,--月底余额
0 as yue,--当前余额
max(yewuName)  as yewuName,--业务员
max(yewudate) as yewudate,--业务提成时间
max(kefuName) as  kefuName,--客服人员（企业的）
QyNo,--企业编号
max(QyName) as QyName,--企业名称
dbo.Getmax(
(select sum(yuangong_all) from 
(
select dbo.Getmax(max(M_fwf_yuangongZuidi),
--SUM(CASE WHEN is_dabaoyewu='是' THEN  M_fwf_Biaozhun-M_fwf_Youhui ELSE 0 END )
 SUM(
 CASE
  WHEN is_dabaoyewu='是' AND ProYuanGong_koufeiType=1  THEN  M_fwf_Biaozhun-M_fwf_Youhui
  WHEN is_dabaoyewu='是' AND ProYuanGong_koufeiType=2  THEN  M_fwf_Biaozhun_Qita-M_fwf_Youhui_Qita
  ELSE 0 
 END)
) as yuangong_all
 from etest_zongbu..t_Money_YuanGongProduct as b
where --ProYuanGong_koufeiType=1 AND
 QyNo=a.QyNo 
and DATEDIFF(m,max(a.koufeiDate),b.koufeiDate)=0
group by YGNo
) as cc
)
, max(a.M_fwf_qiyezuidi)
) as fwf ,
--服务费
0 as dif,--代缴费
 'prono_dbyw' as ProNo,--产品编号
'人事服务' as proname ,--产品名称
1 as ProYuanGong_koufeiType,--员工扣费类型
MAX(guanxi_ycx) as guanxi_ycx,--是否为一次性客户
'人事服务费'+
cast(
dbo.Getmax(
(select sum(yuangong_all) from 
(
select dbo.Getmax(max(M_fwf_yuangongZuidi), 
--SUM(CASE WHEN is_dabaoyewu='是' THEN  M_fwf_Biaozhun-M_fwf_Youhui ELSE 0 END)

 SUM(
 CASE
  WHEN is_dabaoyewu='是' AND ProYuanGong_koufeiType=1  THEN  M_fwf_Biaozhun-M_fwf_Youhui
  WHEN is_dabaoyewu='是' AND ProYuanGong_koufeiType=2  THEN  M_fwf_Biaozhun_Qita-M_fwf_Youhui_Qita
  ELSE 0 
 END)


) as yuangong_all
 from etest_zongbu..t_Money_YuanGongProduct as b
where 
QyNo=a.QyNo 
and DATEDIFF(m,max(a.koufeiDate),b.koufeiDate)=0
group by YGNo
) as cc
 )
 , max(a.M_fwf_qiyezuidi)
 )
 as varchar)----服务费
AS context ,--备注信息 
max(a.koufeiDate) as koufeiDate--扣费时间
 from 
etest_zongbu..t_Money_YuanGongProduct as a
where 1=1  
 AND DATEDIFF(M,@dt,koufeiDate)=0---只将历史的存入
AND a.is_dabaoyewu='是'--是 打包业务
AND DATEDIFF(M,'2016-10-10',koufeiDate)0--- 为了不破坏老的数据
group by datediff(m,a.koufeiDate,GETDATE()),QyNo--,ProNo
-------------------------====================================================================----------------------------------------------
UNION ALL
-------------情况1没有产品的企业(收个最低服务费  原来叫做企业产品 现在叫人事服务 代缴费0  )
select 
MAX(ht_stardate) AS ht_stardate  ,--合同开始时间
MAX(ht_enddate) AS ht_enddate ,  -- 合同结束时间
MAX(qyguanxi) AS qyguanxi , ---企业 隶属关系

MAX(qyfuzeRen) AS qyfuzeRen,--企业 负责人
max(DepName) as DepName ,--企业 分部
max(fwstardate) as  fwstardate,
max(fwenddate)  as fwenddate,
0 as M_fwf_Zhongjie,--中介服务费
0 as M_djf_Zhongjie ,--中介代缴费
0 as yue_yuedi,--月底余额
0 as yue,--当前余额
max(yewuName)  as yewuName,--业务员
max(yewudate) as yewudate,--业务提成时间
max(kefuName) as  kefuName,--客服人员（企业的）
QyNo,--企业编号
max(QyName) as QyName,--企业名称
max(a.M_fwf_qiyezuidi)as fwf ,--服务费
0as dif,--代缴费
 'prono_dbyw' as ProNo,--产品编号
'人事服务' as proname ,--产品名称
1 as ProYuanGong_koufeiType,--员工扣费类型
MAX(guanxi_ycx) as guanxi_ycx,--是否为一次性客户
'人事服务费'+cast(max(a.M_fwf_qiyezuidi)  as varchar) AS context ,----服务费 --备注信息 
max(a.koufeiDate) as koufeiDate--扣费时间
from 
etest_zongbu..t_Money_YuanGongProduct as a
where 1=1  
 AND DATEDIFF(M,@dt,koufeiDate)=0---只将历史的存入
AND a.ProNo IS NULL --说明 是没有产品的企业
AND DATEDIFF(M,'2016-10-10',koufeiDate)0--- 为了不破坏老的数据
group by datediff(m,a.koufeiDate,GETDATE()),QyNo--,ProNo

UNION ALL
-----------情况2没有打包产品 但是有产品的企业 收个最低服务费
SELECT 
MAX(ht_stardate) AS ht_stardate  ,--合同开始时间
MAX(ht_enddate) AS ht_enddate ,  -- 合同结束时间
MAX(qyguanxi) AS qyguanxi , ---企业 隶属关系

MAX(qyfuzeRen) AS qyfuzeRen,--企业 负责人
max(DepName) as DepName ,--企业 分部
max(fwstardate) as  fwstardate,
max(fwenddate)  as fwenddate,
0 as M_fwf_Zhongjie,--中介服务费
0 as M_djf_Zhongjie ,--中介代缴费
0 as yue_yuedi,--月底余额
0 as yue,--当前余额
max(yewuName)  as yewuName,--业务员
max(yewudate) as yewudate,--业务提成时间
max(kefuName) as  kefuName,--客服人员（企业的）
QyNo,--企业编号
max(QyName) as QyName,--企业名称
MAX(M_fwf_qiyezuidi) as fwf,--服务费
0 as dif,--代缴费
'prono_dbyw' as ProNo,--产品编号
'人事服务' as proname ,--产品名称
1 as ProYuanGong_koufeiType,--员工扣费类型
MAX(guanxi_ycx) as guanxi_ycx,--是否为一次性客户
'人事服务费'+cast( MAX(M_fwf_qiyezuidi) as varchar) AS context --备注信息 ,
,max(koufeiDate) as koufeiDate--扣费时间
FROM
etest_zongbu..t_Money_YuanGongProduct 
WHERE  DATEDIFF(M,@dt,koufeiDate)=0 --只将历史的存入
AND   ProNo IS NOT NULL----说明有产品
AND DATEDIFF(M,'2016-10-10',koufeiDate)0--- 为了不破坏老的数据
AND   QYNo
NOT IN--说明没有打包产品
(
SELECT QYNo FROM
etest_zongbu..t_Money_YuanGongProduct 
WHERE  DATEDIFF(M,@dt,koufeiDate)=0 
AND 
is_dabaoyewu ='是'
)
GROUP BY qyno


----------=================================================================结束================================================================---------------------------------
----------===================================================删掉费用为0的==============================================================================---------------------------------
DELETE etest_zongbu..T_Money_qiye WHERE fwf+dif =0 AND DATEDIFF(M,@dt,koufeiDate)=0 AND  DATEDIFF(M,'2016-10-10',koufeiDate)0
end 
end




