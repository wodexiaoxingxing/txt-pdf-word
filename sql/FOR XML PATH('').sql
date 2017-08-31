SELECT ZHB.hebing_Code,ZHB.luru_man,ZHB.luru_date,act,LEFT(HeBingLie,LEN(HeBingLie)) as HeBingLie 
FROM (
SELECT hebing_Code,MAX(luru_man) AS luru_man, MAX(luru_date) AS luru_date,MAX(act) AS act, 
(SELECT geren_IdCard+','+geren_Name+'[换行]' FROM etest_zongbu.dbo.dz_hebingkehu 
WHERE hebing_Code=HB.hebing_Code FOR XML PATH('') 
) AS HeBingLie 
FROM etest_zongbu.dbo.dz_hebingkehu AS HB
 WHERE del=0 AND HB.kehuType='个人客户' 
GROUP BY HB.hebing_Code
) ZHB 


select 
(SELECT distinct  CompanyNo+',' FROM etest_zongbu.dbo.T_Customer_QiyeYuangongProduct 
WHERE QYNo=gx.qn AND gx.guanxi>0 AND guanxi='是'  FOR XML PATH('') 
) AS lishu_gongsi_companyno ,
(SELECT  DISTINCT CompanyNo+',' FROM etest_zongbu.dbo.T_Customer_QiyeYuangongProduct 
WHERE QYNo=gx.qn AND gx.guanxi=0 AND guanxi='否'  FOR XML PATH('') 
) AS lishu_gongsi_companyno ,
guanxi,
* 

from etest_zongbu.dbo.T_Customer_Qiye qy 
LEFT JOIN 
( SELECT qy.QyNo AS qn,
SUM(CASE WHEN (ygyw.guanxi = '是') THEN 1 ELSE 0 END ) AS guanxi 
FROM etest_zongbu.dbo.T_Customer_Qiye qy 
LEFT JOIN etest_zongbu.dbo.T_Customer_QiyeYuangongProduct ygyw 
ON qy.QyNo = ygyw.QYNo 
GROUP BY qy.QyNo 
) gx 
ON qy.QyNo = gx.qn 
where 1 = 1 and ActFalg = 1
AND qy.QyName LIKE '%海南碧凯药业有限公司%'
 order by CreateDate desc 