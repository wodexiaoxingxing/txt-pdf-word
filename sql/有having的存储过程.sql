USE [etest_zongbu]
GO
 Object  StoredProcedure [dbo].[Pr_Money_qiye]    Script Date 03062017 142445 
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

---ԭ���ı�   T_Money_qiye
---Ϊ�˲����½��ı� T_Money_qiye

--  select M_fwf_Zhongjie, from  etest_zongbu..T_Money_qiye where prono='prono_dbyw' and M_fwf_Zhongjie0
--   update etest_zongbu..T_Money_qiye  set M_fwf_Zhongjie=0 where proname='���·���' and M_fwf_Zhongjie0
--delete etest_zongbu..T_Money_qiye 

---���� ִ�� �洢���� exec  [dbo].[Pr_Money_qiye_����]  '2016-11-30'

ALTER        PROCEDURE [dbo].[Pr_Money_qiye] 
   @dt     datetime

AS
BEGIN 

if @dt='' or @dt =null
begin
delete from etest_zongbu..T_Money_qiye WHERE DATEDIFF(m,'2016-10-10',koufeiDate)0---Ϊ�˲��ƻ���ʷ����
insert into etest_zongbu..T_Money_qiye
(
ht_stardate  ,--��ͬ��ʼʱ��
ht_enddate  ,  -- ��ͬ����ʱ��
qyguanxi , ---��ҵ ������ϵ

qyfuzeRen,DepName,
fwstardate,fwenddate,
M_fwf_Zhongjie,M_djf_Zhongjie,
Mtotal_yue_EndMonth,Mtotal_yue_Curr,
yewuName,yewudate,kefuName,QyNo,QyName,
fwf,dif,ProNo,proname,
ProYuanGong_koufeiType,guanxi_ycx,context,koufeiDate)
--=======�������ˮ
----���4 ���в�Ʒ����Ĵ��ɷ�  �����(�����������Ʒ�ķ����)
select 
MAX(ht_stardate) AS ht_stardate  ,--��ͬ��ʼʱ��
MAX(ht_enddate) AS ht_enddate ,  -- ��ͬ����ʱ��
MAX(qyguanxi) AS qyguanxi , ---��ҵ ������ϵ

MAX(qyfuzeRen)AS qyfuzeRen,--��ҵ������
max(DepName) as DepName ,--��ҵ �ֲ�
max(fwstardate) as  fwstardate,
max(fwenddate)  as fwenddate,
SUM(isnull(M_fwf_Zhongjie,0)) as M_fwf_Zhongjie,--�н�����
SUM(isnull(M_djf_Zhongjie,0)) as M_djf_Zhongjie ,--�н���ɷ�
0 as yue_yuedi,--�µ����
0 as yue,--��ǰ���
max(yewuName)  as yewuName,--ҵ��Ա
max(yewudate) as yewudate,--ҵ�����ʱ��
max(kefuName) as  kefuName,--�ͷ���Ա����ҵ�ģ�
QyNo,--��ҵ���
max(QyName) as QyName,--��ҵ����
--CASE WHEN MAX(is_dabaoyewu)='��' THEN  0 ELSE SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita) END as fwf,--�����
CASE WHEN MAX(ProYuanGong_koufeiType)=1 THEN
CASE WHEN MAX(is_dabaoyewu)='��' THEN 0 ELSE  SUM(a.M_fwf_Biaozhun-a.M_fwf_Youhui) END 
WHEN  MAX(ProYuanGong_koufeiType)=2 THEN  
CASE WHEN MAX(is_dabaoyewu)='��' THEN 0 ELSE  SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita) END
ELSE 
0
END as fwf, --�����


SUM(a.M_djf_Biaozhun) as dif,---���ɷ�
ProNo,--��Ʒ���
MAX(proname) as proname,--��Ʒ����
MAX(ProYuanGong_koufeiType) as ProYuanGong_koufeiType,--Ա���۷�����
MAX(guanxi_ycx) as guanxi_ycx,--�Ƿ�Ϊһ���Կͻ�

'�����'+replace(isnull(cast(SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita) as varchar),''),'.000000','')+'��'
 +max(ProName)+'���ɷ�'+replace(isnull(cast(SUM(a.M_djf_Biaozhun) as varchar),''),'.000000','')+'��'  as context,---��ע��Ϣ

 CASE WHEN MAX(is_dabaoyewu)='��' AND SUM(a.M_djf_Biaozhun)0 THEN  max(a.ProName)+'���ɷ�'+replace(isnull(cast(SUM(a.M_djf_Biaozhun) as varchar),''),'.000000','') 
WHEN   MAX(is_dabaoyewu)='��' AND SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita)0 AND SUM(a.M_djf_Biaozhun)=0 THEN '�����'+replace(isnull(cast( SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita)  as varchar),''),'.000000','')--+';'
WHEN MAX(is_dabaoyewu)='��' AND SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita)=0 AND SUM(a.M_djf_Biaozhun)0 THEN max(ProName)+'���ɷ�'+replace(isnull(cast(SUM(a.M_djf_Biaozhun) as varchar),''),'.000000','') 
WHEN MAX(is_dabaoyewu)='��' AND SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita)0 AND SUM(a.M_djf_Biaozhun)0 THEN '�����'+replace(isnull(cast( SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita)  as varchar),''),'.000000','')+';'+max(ProName)+'���ɷ�'+replace(isnull(cast(SUM(a.M_djf_Biaozhun) as varchar),''),'.000000','') 
ELSE ''
END 
as context,---��ע��Ϣ
 
 CASE WHEN MAX(ProYuanGong_koufeiType)=1 THEN 
CASE WHEN MAX(is_dabaoyewu)='��' AND SUM(a.M_djf_Biaozhun)0 THEN  max(ProName)+'���ɷ�'+replace(isnull(cast(SUM(a.M_djf_Biaozhun) as varchar),''),'.000000','') 
WHEN   MAX(is_dabaoyewu)='��' AND SUM(a.M_fwf_Biaozhun-a.M_fwf_Youhui)0 AND SUM(a.M_djf_Biaozhun)=0 THEN '�����'+replace(isnull(cast( SUM(a.M_fwf_Biaozhun-a.M_fwf_Youhui)  as varchar),''),'.000000','')--+';'
WHEN MAX(is_dabaoyewu)='��' AND SUM(a.M_fwf_Biaozhun-a.M_fwf_Youhui)=0 AND SUM(a.M_djf_Biaozhun)0 THEN max(ProName)+'���ɷ�'+replace(isnull(cast(SUM(a.M_djf_Biaozhun) as varchar),''),'.000000','') 
WHEN MAX(is_dabaoyewu)='��' AND SUM(a.M_fwf_Biaozhun-a.M_fwf_Youhui)0 AND SUM(a.M_djf_Biaozhun)0 THEN '�����'+replace(isnull(cast( SUM(a.M_fwf_Biaozhun-a.M_fwf_Youhui)  as varchar),''),'.000000','')+';'+max(ProName)+'���ɷ�'+replace(isnull(cast(SUM(a.M_djf_Biaozhun) as varchar),''),'.000000','') 
ELSE ''
END 
WHEN  MAX(ProYuanGong_koufeiType)=2 THEN  
CASE WHEN MAX(is_dabaoyewu)='��' AND SUM(a.M_djf_Biaozhun)0 THEN  max(ProName)+'���ɷ�'+replace(isnull(cast(SUM(a.M_djf_Biaozhun) as varchar),''),'.000000','') 
WHEN   MAX(is_dabaoyewu)='��' AND SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita)0 AND SUM(a.M_djf_Biaozhun)=0 THEN '�����'+replace(isnull(cast( SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita)  as varchar),''),'.000000','')--+';'
WHEN MAX(is_dabaoyewu)='��' AND SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita)=0 AND SUM(a.M_djf_Biaozhun)0 THEN max(ProName)+'���ɷ�'+replace(isnull(cast(SUM(a.M_djf_Biaozhun) as varchar),''),'.000000','') 
WHEN MAX(is_dabaoyewu)='��' AND SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita)0 AND SUM(a.M_djf_Biaozhun)0 THEN '�����'+replace(isnull(cast( SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita)  as varchar),''),'.000000','')+';'+max(ProName)+'���ɷ�'+replace(isnull(cast(SUM(a.M_djf_Biaozhun) as varchar),''),'.000000','') 
ELSE ''
END 
ELSE 
''
END
 as context,---��ע��Ϣ
 
 max(a.koufeiDate)  as koufeiDate--�۷�ʱ��
 from 
etest_zongbu..t_Money_YuanGongProduct as a
where --ProYuanGong_koufeiType=2 --and ---��������
1=1
AND  DATEDIFF(M,'2016-10-10',koufeiDate)0---Ϊ�˲��ƻ���ʷ����
group by datediff(m,koufeiDate,GETDATE()),QyNo,ProNo
union ALL
----------=================================================================================================================================---------------------------------
----���3���д����Ʒ ����ҵΪ��λ    ����ķ����
select 
MAX(ht_stardate) AS ht_stardate  ,--��ͬ��ʼʱ��
MAX(ht_enddate) AS ht_enddate ,  -- ��ͬ����ʱ��
MAX(qyguanxi) AS qyguanxi , ---��ҵ ������ϵ

MAX(qyfuzeRen) AS qyfuzeRen,--��ҵ ������
max(DepName) as DepName ,--��ҵ �ֲ�
max(fwstardate) as  fwstardate,
max(fwenddate)  as fwenddate,
0 as M_fwf_Zhongjie,--�н�����
0 as M_djf_Zhongjie ,--�н���ɷ�
0 as yue_yuedi,--�µ����
0 as yue,--��ǰ���
max(yewuName)  as yewuName,--ҵ��Ա
max(yewudate) as yewudate,--ҵ�����ʱ��
max(kefuName) as  kefuName,--�ͷ���Ա����ҵ�ģ�
QyNo,--��ҵ���
max(QyName) as QyName,--��ҵ����
dbo.Getmax(
(select sum(yuangong_all) from 
(
select dbo.Getmax(max(M_fwf_yuangongZuidi),
 --SUM(CASE WHEN is_dabaoyewu ='��' THEN  M_fwf_Biaozhun-M_fwf_Youhui ELSE 0 END )
  SUM(
 CASE
  WHEN is_dabaoyewu='��' AND ProYuanGong_koufeiType=1  THEN  M_fwf_Biaozhun-M_fwf_Youhui
  WHEN is_dabaoyewu='��' AND ProYuanGong_koufeiType=2  THEN  M_fwf_Biaozhun_Qita-M_fwf_Youhui_Qita
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
--�����
0 as dif,--���ɷ�
 'prono_dbyw' as ProNo,--��Ʒ���
'���·���' as proname ,--��Ʒ����
1 as ProYuanGong_koufeiType,--Ա���۷�����
MAX(guanxi_ycx) as guanxi_ycx,--�Ƿ�Ϊһ���Կͻ�
'���·����'+
cast(
dbo.Getmax(
(select sum(yuangong_all) from 
(
select dbo.Getmax(max(M_fwf_yuangongZuidi),
 --SUM(CASE WHEN is_dabaoyewu ='��' THEN  M_fwf_Biaozhun-M_fwf_Youhui ELSE 0 END)
  SUM(
 CASE
  WHEN is_dabaoyewu='��' AND ProYuanGong_koufeiType=1  THEN  M_fwf_Biaozhun-M_fwf_Youhui
  WHEN is_dabaoyewu='��' AND ProYuanGong_koufeiType=2  THEN  M_fwf_Biaozhun_Qita-M_fwf_Youhui_Qita
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
 as varchar)----�����
 AS context --��ע��Ϣ 
,max(a.koufeiDate) as koufeiDate--�۷�ʱ��
 from 
etest_zongbu..t_Money_YuanGongProduct as a
where 1=1  
AND  DATEDIFF(M,'2016-10-10',koufeiDate)0---Ϊ�˲��ƻ���ʷ����
AND  is_dabaoyewu ='��'--���д����Ʒ
group by datediff(m,a.koufeiDate,GETDATE()),QyNo--,ProNo
-------------------------====================================================================----------------------------------------------
UNION ALL
-------------���1û�в�Ʒ����ҵ(�ո���ͷ����  ԭ��������ҵ��Ʒ ���ڽ����·��� ���ɷ�0 )
select 
MAX(ht_stardate) AS ht_stardate  ,--��ͬ��ʼʱ��
MAX(ht_enddate) AS ht_enddate ,  -- ��ͬ����ʱ��
MAX(qyguanxi) AS qyguanxi , ---��ҵ ������ϵ

MAX(qyfuzeRen) AS qyfuzeRen,--��ҵ ������
max(DepName) as DepName ,--��ҵ �ֲ�
max(fwstardate) as  fwstardate,
max(fwenddate)  as fwenddate,
0 as M_fwf_Zhongjie,--�н�����
0 as M_djf_Zhongjie ,--�н���ɷ�
0 as yue_yuedi,--�µ����
0 as yue,--��ǰ���
max(yewuName)  as yewuName,--ҵ��Ա
max(yewudate) as yewudate,--ҵ�����ʱ��
max(kefuName) as  kefuName,--�ͷ���Ա����ҵ�ģ�
QyNo,--��ҵ���
max(QyName) as QyName,--��ҵ����
max(a.M_fwf_qiyezuidi) as fwf ,--�����
0 as dif,--���ɷ�
 'prono_dbyw' as ProNo,--��Ʒ���
'���·���' as proname ,--��Ʒ����
1 as ProYuanGong_koufeiType,--Ա���۷�����
MAX(guanxi_ycx) as guanxi_ycx,--�Ƿ�Ϊһ���Կͻ�
'���·����'+
cast(max(a.M_fwf_qiyezuidi) as varchar)----�����
 AS context ,--��ע��Ϣ 
max(a.koufeiDate) as koufeiDate--�۷�ʱ��
 from 
etest_zongbu..t_Money_YuanGongProduct as a
where 1=1  
AND  DATEDIFF(M,'2016-10-10',koufeiDate)0---Ϊ�˲��ƻ���ʷ����
 AND a.ProNo IS NULL --˵����û�в�Ʒ��  ��ҵ
group by datediff(m,a.koufeiDate,GETDATE()),QyNo--,ProNo

UNION ALL
-----------���2û�д����Ʒ �����в�Ʒ����ҵ �ո���ͷ����
SELECT 
MAX(ht_stardate) AS ht_stardate  ,--��ͬ��ʼʱ��
MAX(ht_enddate) AS ht_enddate ,  -- ��ͬ����ʱ��
MAX(qyguanxi) AS qyguanxi , ---��ҵ ������ϵ

MAX(qyfuzeRen) AS qyfuzeRen,--��ҵ ������
max(DepName) as DepName ,--��ҵ �ֲ�
max(fwstardate) as  fwstardate,
max(fwenddate)  as fwenddate,
0 as M_fwf_Zhongjie,--�н�����
0 as M_djf_Zhongjie ,--�н���ɷ�
0 as yue_yuedi,--�µ����
0 as yue,--��ǰ���
max(yewuName)  as yewuName,--ҵ��Ա
max(yewudate) as yewudate,--ҵ�����ʱ��
max(kefuName) as  kefuName,--�ͷ���Ա����ҵ�ģ�
QyNo,--��ҵ���
max(QyName) as QyName,--��ҵ����
MAX(M_fwf_qiyezuidi) as fwf,--�����
0 as dif,--���ɷ�
 'prono_dbyw' as ProNo,--��Ʒ���
'���·���' as proname ,--��Ʒ����
1 as ProYuanGong_koufeiType,--Ա���۷�����
MAX(guanxi_ycx) as guanxi_ycx,--�Ƿ�Ϊһ���Կͻ�
'���·����'+cast( MAX(M_fwf_qiyezuidi) as varchar) AS context --��ע��Ϣ ,
,max(koufeiDate) as koufeiDate--�۷�ʱ��
FROM etest_zongbu..t_Money_YuanGongProduct AS a
WHERE 1=1 AND    ProNo IS NOT NULL--˵���в�Ʒ 
AND  DATEDIFF(M,'2016-10-10',koufeiDate)0---Ϊ�˲��ƻ���ʷ����
GROUP BY  DATEDIFF(M,GETDATE(),koufeiDate),QYNo
--ORDER BY  MAX(koufeiDate)
HAVING a.qyno   --˵��û�д����Ʒ
NOT IN
(
SELECT qyno FROM etest_zongbu..t_Money_YuanGongProduct 
WHERE 1=1 AND    
 is_dabaoyewu ='��'
AND   DATEDIFF(M,koufeiDate,MAX(a.koufeiDate))=0
)
ORDER BY  MAX(a.koufeiDate)
----------=================================================================����================================================================---------------------------------
----------=======================================================ɾ������Ϊ0��===========================================================================---------------------------------

DELETE etest_zongbu..T_Money_qiye WHERE fwf+dif =0 AND  DATEDIFF(M,'2016-10-10',koufeiDate)0---Ϊ�˲��ƻ���ʷ����
END
----------=================================================================================================================================---------------------------------
if @dt'' and @dtnull
begin
delete from etest_zongbu..T_Money_qiye where DATEDIFF(M,@dt,koufeiDate)=0 AND  DATEDIFF(M,'2016-10-10',koufeiDate)0
insert into etest_zongbu..T_Money_qiye
(
ht_stardate  ,--��ͬ��ʼʱ��
 ht_enddate ,  -- ��ͬ����ʱ��
 qyguanxi , ---��ҵ ������ϵ
qyfuzeRen,DepName,fwstardate,fwenddate,
M_fwf_Zhongjie,M_djf_Zhongjie,Mtotal_yue_EndMonth,Mtotal_yue_Curr,
yewuName,yewudate,kefuName,QyNo,QyName,fwf,dif,ProNo,proname,ProYuanGong_koufeiType,guanxi_ycx,context,koufeiDate)
--=======�������ˮ
----���4 ���в�Ʒ����Ĵ��ɷ�  �����(�����������Ʒ�ķ����)
select 
MAX(ht_stardate) AS ht_stardate  ,--��ͬ��ʼʱ��
MAX(ht_enddate) AS ht_enddate ,  -- ��ͬ����ʱ��
MAX(qyguanxi) AS qyguanxi , ---��ҵ ������ϵ

MAX(qyfuzeRen) AS qyfuzeRen,--��ҵ������
max(DepName) as DepName ,--��ҵ �ֲ�
max(fwstardate) as  fwstardate,
max(fwenddate)  as fwenddate,
SUM(isnull(M_fwf_Zhongjie,0)) as M_fwf_Zhongjie,--�н�����
SUM(isnull(M_djf_Zhongjie,0)) as M_djf_Zhongjie ,--�н���ɷ�
0 as yue_yuedi,--�µ����
0 as yue,--��ǰ���
max(yewuName)  as yewuName,--ҵ��Ա
max(yewudate) as yewudate,--ҵ�����ʱ��
max(kefuName) as  kefuName,--�ͷ���Ա����ҵ�ģ�
QyNo,--��ҵ���
max(QyName) as QyName,--��ҵ����
--CASE WHEN MAX(is_dabaoyewu)='��' THEN 0 ELSE  SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita) END as fwf,--�����


CASE WHEN MAX(ProYuanGong_koufeiType)=1 THEN
CASE WHEN MAX(is_dabaoyewu)='��' THEN 0 ELSE  SUM(a.M_fwf_Biaozhun-a.M_fwf_Youhui) END 
WHEN  MAX(ProYuanGong_koufeiType)=2 THEN  
CASE WHEN MAX(is_dabaoyewu)='��' THEN 0 ELSE  SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita) END
ELSE 
0
END as fwf, --�����

SUM(a.M_djf_Biaozhun) as dif,---���ɷ�
ProNo,--��Ʒ���
MAX(proname) as proname,--��Ʒ����
MAX(ProYuanGong_koufeiType) as ProYuanGong_koufeiType,--Ա���۷�����
MAX(guanxi_ycx) as guanxi_ycx,--�Ƿ�Ϊһ���Կͻ�

'�����'+replace(isnull(cast(SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita) as varchar),''),'.000000','')+'��'
 +max(ProName)+'���ɷ�'+replace(isnull(cast(SUM(a.M_djf_Biaozhun) as varchar),''),'.000000','')+'��' 
 
CASE WHEN MAX(is_dabaoyewu)='��' AND SUM(a.M_djf_Biaozhun)0 THEN  max(a.ProName)+'���ɷ�'+replace(isnull(cast(SUM(a.M_djf_Biaozhun) as varchar),''),'.000000','') 
WHEN   MAX(is_dabaoyewu)='��' AND SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita)0 AND SUM(a.M_djf_Biaozhun)=0 THEN '�����'+replace(isnull(cast( SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita)  as varchar),''),'.000000','')--+';'
WHEN MAX(is_dabaoyewu)='��' AND SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita)=0 AND SUM(a.M_djf_Biaozhun)0 THEN max(ProName)+'���ɷ�'+replace(isnull(cast(SUM(a.M_djf_Biaozhun) as varchar),''),'.000000','') 
WHEN MAX(is_dabaoyewu)='��' AND SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita)0 AND SUM(a.M_djf_Biaozhun)0 THEN '�����'+replace(isnull(cast( SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita)  as varchar),''),'.000000','')+';'+max(ProName)+'���ɷ�'+replace(isnull(cast(SUM(a.M_djf_Biaozhun) as varchar),''),'.000000','') 
ELSE ''
END 
as context,---��ע��Ϣ


CASE WHEN MAX(ProYuanGong_koufeiType)=1 THEN 
CASE WHEN MAX(is_dabaoyewu)='��' AND SUM(a.M_djf_Biaozhun)0 THEN  max(ProName)+'���ɷ�'+replace(isnull(cast(SUM(a.M_djf_Biaozhun) as varchar),''),'.000000','') 
WHEN   MAX(is_dabaoyewu)='��' AND SUM(a.M_fwf_Biaozhun-a.M_fwf_Youhui)0 AND SUM(a.M_djf_Biaozhun)=0 THEN '�����'+replace(isnull(cast( SUM(a.M_fwf_Biaozhun-a.M_fwf_Youhui)  as varchar),''),'.000000','')--+';'
WHEN MAX(is_dabaoyewu)='��' AND SUM(a.M_fwf_Biaozhun-a.M_fwf_Youhui)=0 AND SUM(a.M_djf_Biaozhun)0 THEN max(ProName)+'���ɷ�'+replace(isnull(cast(SUM(a.M_djf_Biaozhun) as varchar),''),'.000000','') 
WHEN MAX(is_dabaoyewu)='��' AND SUM(a.M_fwf_Biaozhun-a.M_fwf_Youhui)0 AND SUM(a.M_djf_Biaozhun)0 THEN '�����'+replace(isnull(cast( SUM(a.M_fwf_Biaozhun-a.M_fwf_Youhui)  as varchar),''),'.000000','')+';'+max(ProName)+'���ɷ�'+replace(isnull(cast(SUM(a.M_djf_Biaozhun) as varchar),''),'.000000','') 
ELSE ''
END 
WHEN  MAX(ProYuanGong_koufeiType)=2 THEN  
CASE WHEN MAX(is_dabaoyewu)='��' AND SUM(a.M_djf_Biaozhun)0 THEN  max(ProName)+'���ɷ�'+replace(isnull(cast(SUM(a.M_djf_Biaozhun) as varchar),''),'.000000','') 
WHEN   MAX(is_dabaoyewu)='��' AND SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita)0 AND SUM(a.M_djf_Biaozhun)=0 THEN '�����'+replace(isnull(cast( SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita)  as varchar),''),'.000000','')--+';'
WHEN MAX(is_dabaoyewu)='��' AND SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita)=0 AND SUM(a.M_djf_Biaozhun)0 THEN max(ProName)+'���ɷ�'+replace(isnull(cast(SUM(a.M_djf_Biaozhun) as varchar),''),'.000000','') 
WHEN MAX(is_dabaoyewu)='��' AND SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita)0 AND SUM(a.M_djf_Biaozhun)0 THEN '�����'+replace(isnull(cast( SUM(a.M_fwf_Biaozhun_Qita-a.M_fwf_Youhui_Qita)  as varchar),''),'.000000','')+';'+max(ProName)+'���ɷ�'+replace(isnull(cast(SUM(a.M_djf_Biaozhun) as varchar),''),'.000000','') 
ELSE ''
END 
ELSE 
''
END
 as context,---��ע��Ϣ




 
 max(a.koufeiDate)  as koufeiDate--�۷�ʱ��
 from 
etest_zongbu..t_Money_YuanGongProduct as a
where --ProYuanGong_koufeiType=2 --and ---��������
 DATEDIFF(M,'2016-10-10',koufeiDate)0--- Ϊ�˲��ƻ��ϵ�����
and DATEDIFF(M,@dt,koufeiDate)=0
group by datediff(m,koufeiDate,GETDATE()),QyNo,ProNo
union ALL
----------=================================================================================================================================---------------------------------
----------------------------------���3���д����Ʒ ����ҵΪ��λ    ����ķ����
select 
MAX(ht_stardate) AS ht_stardate  ,--��ͬ��ʼʱ��
MAX(ht_enddate) AS ht_enddate ,  -- ��ͬ����ʱ��
MAX(qyguanxi) AS qyguanxi , ---��ҵ ������ϵ

MAX(qyfuzeRen) AS qyfuzeRen,--��ҵ ������
max(DepName) as DepName ,--��ҵ �ֲ�
max(fwstardate) as  fwstardate,
max(fwenddate)  as fwenddate,
0 as M_fwf_Zhongjie,--�н�����
0 as M_djf_Zhongjie ,--�н���ɷ�
0 as yue_yuedi,--�µ����
0 as yue,--��ǰ���
max(yewuName)  as yewuName,--ҵ��Ա
max(yewudate) as yewudate,--ҵ�����ʱ��
max(kefuName) as  kefuName,--�ͷ���Ա����ҵ�ģ�
QyNo,--��ҵ���
max(QyName) as QyName,--��ҵ����
dbo.Getmax(
(select sum(yuangong_all) from 
(
select dbo.Getmax(max(M_fwf_yuangongZuidi),
--SUM(CASE WHEN is_dabaoyewu='��' THEN  M_fwf_Biaozhun-M_fwf_Youhui ELSE 0 END )
 SUM(
 CASE
  WHEN is_dabaoyewu='��' AND ProYuanGong_koufeiType=1  THEN  M_fwf_Biaozhun-M_fwf_Youhui
  WHEN is_dabaoyewu='��' AND ProYuanGong_koufeiType=2  THEN  M_fwf_Biaozhun_Qita-M_fwf_Youhui_Qita
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
--�����
0 as dif,--���ɷ�
 'prono_dbyw' as ProNo,--��Ʒ���
'���·���' as proname ,--��Ʒ����
1 as ProYuanGong_koufeiType,--Ա���۷�����
MAX(guanxi_ycx) as guanxi_ycx,--�Ƿ�Ϊһ���Կͻ�
'���·����'+
cast(
dbo.Getmax(
(select sum(yuangong_all) from 
(
select dbo.Getmax(max(M_fwf_yuangongZuidi), 
--SUM(CASE WHEN is_dabaoyewu='��' THEN  M_fwf_Biaozhun-M_fwf_Youhui ELSE 0 END)

 SUM(
 CASE
  WHEN is_dabaoyewu='��' AND ProYuanGong_koufeiType=1  THEN  M_fwf_Biaozhun-M_fwf_Youhui
  WHEN is_dabaoyewu='��' AND ProYuanGong_koufeiType=2  THEN  M_fwf_Biaozhun_Qita-M_fwf_Youhui_Qita
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
 as varchar)----�����
AS context ,--��ע��Ϣ 
max(a.koufeiDate) as koufeiDate--�۷�ʱ��
 from 
etest_zongbu..t_Money_YuanGongProduct as a
where 1=1  
 AND DATEDIFF(M,@dt,koufeiDate)=0---ֻ����ʷ�Ĵ���
AND a.is_dabaoyewu='��'--�� ���ҵ��
AND DATEDIFF(M,'2016-10-10',koufeiDate)0--- Ϊ�˲��ƻ��ϵ�����
group by datediff(m,a.koufeiDate,GETDATE()),QyNo--,ProNo
-------------------------====================================================================----------------------------------------------
UNION ALL
-------------���1û�в�Ʒ����ҵ(�ո���ͷ����  ԭ��������ҵ��Ʒ ���ڽ����·��� ���ɷ�0  )
select 
MAX(ht_stardate) AS ht_stardate  ,--��ͬ��ʼʱ��
MAX(ht_enddate) AS ht_enddate ,  -- ��ͬ����ʱ��
MAX(qyguanxi) AS qyguanxi , ---��ҵ ������ϵ

MAX(qyfuzeRen) AS qyfuzeRen,--��ҵ ������
max(DepName) as DepName ,--��ҵ �ֲ�
max(fwstardate) as  fwstardate,
max(fwenddate)  as fwenddate,
0 as M_fwf_Zhongjie,--�н�����
0 as M_djf_Zhongjie ,--�н���ɷ�
0 as yue_yuedi,--�µ����
0 as yue,--��ǰ���
max(yewuName)  as yewuName,--ҵ��Ա
max(yewudate) as yewudate,--ҵ�����ʱ��
max(kefuName) as  kefuName,--�ͷ���Ա����ҵ�ģ�
QyNo,--��ҵ���
max(QyName) as QyName,--��ҵ����
max(a.M_fwf_qiyezuidi)as fwf ,--�����
0as dif,--���ɷ�
 'prono_dbyw' as ProNo,--��Ʒ���
'���·���' as proname ,--��Ʒ����
1 as ProYuanGong_koufeiType,--Ա���۷�����
MAX(guanxi_ycx) as guanxi_ycx,--�Ƿ�Ϊһ���Կͻ�
'���·����'+cast(max(a.M_fwf_qiyezuidi)  as varchar) AS context ,----����� --��ע��Ϣ 
max(a.koufeiDate) as koufeiDate--�۷�ʱ��
from 
etest_zongbu..t_Money_YuanGongProduct as a
where 1=1  
 AND DATEDIFF(M,@dt,koufeiDate)=0---ֻ����ʷ�Ĵ���
AND a.ProNo IS NULL --˵�� ��û�в�Ʒ����ҵ
AND DATEDIFF(M,'2016-10-10',koufeiDate)0--- Ϊ�˲��ƻ��ϵ�����
group by datediff(m,a.koufeiDate,GETDATE()),QyNo--,ProNo

UNION ALL
-----------���2û�д����Ʒ �����в�Ʒ����ҵ �ո���ͷ����
SELECT 
MAX(ht_stardate) AS ht_stardate  ,--��ͬ��ʼʱ��
MAX(ht_enddate) AS ht_enddate ,  -- ��ͬ����ʱ��
MAX(qyguanxi) AS qyguanxi , ---��ҵ ������ϵ

MAX(qyfuzeRen) AS qyfuzeRen,--��ҵ ������
max(DepName) as DepName ,--��ҵ �ֲ�
max(fwstardate) as  fwstardate,
max(fwenddate)  as fwenddate,
0 as M_fwf_Zhongjie,--�н�����
0 as M_djf_Zhongjie ,--�н���ɷ�
0 as yue_yuedi,--�µ����
0 as yue,--��ǰ���
max(yewuName)  as yewuName,--ҵ��Ա
max(yewudate) as yewudate,--ҵ�����ʱ��
max(kefuName) as  kefuName,--�ͷ���Ա����ҵ�ģ�
QyNo,--��ҵ���
max(QyName) as QyName,--��ҵ����
MAX(M_fwf_qiyezuidi) as fwf,--�����
0 as dif,--���ɷ�
'prono_dbyw' as ProNo,--��Ʒ���
'���·���' as proname ,--��Ʒ����
1 as ProYuanGong_koufeiType,--Ա���۷�����
MAX(guanxi_ycx) as guanxi_ycx,--�Ƿ�Ϊһ���Կͻ�
'���·����'+cast( MAX(M_fwf_qiyezuidi) as varchar) AS context --��ע��Ϣ ,
,max(koufeiDate) as koufeiDate--�۷�ʱ��
FROM
etest_zongbu..t_Money_YuanGongProduct 
WHERE  DATEDIFF(M,@dt,koufeiDate)=0 --ֻ����ʷ�Ĵ���
AND   ProNo IS NOT NULL----˵���в�Ʒ
AND DATEDIFF(M,'2016-10-10',koufeiDate)0--- Ϊ�˲��ƻ��ϵ�����
AND   QYNo
NOT IN--˵��û�д����Ʒ
(
SELECT QYNo FROM
etest_zongbu..t_Money_YuanGongProduct 
WHERE  DATEDIFF(M,@dt,koufeiDate)=0 
AND 
is_dabaoyewu ='��'
)
GROUP BY qyno


----------=================================================================����================================================================---------------------------------
----------===================================================ɾ������Ϊ0��==============================================================================---------------------------------
DELETE etest_zongbu..T_Money_qiye WHERE fwf+dif =0 AND DATEDIFF(M,@dt,koufeiDate)=0 AND  DATEDIFF(M,'2016-10-10',koufeiDate)0
end 
end




