SELECT  
cast(haoduan_danhao as int) - row_number() over(partition by haoduan order by haoduan_danhao ASC  ) as rownum
,* FROM  etest_zongbu.[dbo].[T_shouju_ruku_biao]
WHERE 1=1 AND 1=1 AND DATEDIFF(m,ruku_shijian,@dt)=0 ---加上个时间条件 ruku_shijian 入库时间
) AS ruku_qizhi_hao WHERE 1=1 
GROUP BY haoduan,rownum