

if object_id(N'etest_e_backups.dbo.yewu',N'U') is not null
BEGIN 
    print '´æÔÚ'
    DROP TABLE  etest_e_backups..yewu 
END  
ELSE
BEGIN 
   print '²»´æÔÚ'
   SELECT * INTO etest_e_backups..yewu
   FROM etest_zongbu..YeWu
END 
    




