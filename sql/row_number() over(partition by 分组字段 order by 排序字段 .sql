SELECT  
cast(haoduan_danhao as int) - row_number() over(partition by haoduan order by haoduan_danhao ASC  ) as rownum
,* FROM  etest_zongbu.[dbo].[T_shouju_ruku_biao]
WHERE 1=1 AND 1=1 AND DATEDIFF(m,ruku_shijian,@dt)=0 ---���ϸ�ʱ������ ruku_shijian ���ʱ��
) AS ruku_qizhi_hao WHERE 1=1 
GROUP BY haoduan,rownum