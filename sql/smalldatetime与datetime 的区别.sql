    /*  
    smalldatetime 与datetime 的区别
  1:smalldatetime 精确取到分,datetime 精确取到3.33毫秒
  2:时间段不一样 smalldatetime(1900/1/1~2079/6/6)  datetime(1753/1/1~9999/12/31)
  3:smalldatetime 大于等于30秒 四舍五入为1分钟
    */              
DECLARE @dt DATETIME  = DATEADD(m, -2, GETDATE())
WHILE @dt < =GETDATE() 
      BEGIN
          SELECT  @dt 
            SET @dt = DATEADD(m, 1, @dt)
      END 
      
 PRINT '-----------------------------'                       
DECLARE @dt1 SMALLDATETIME  = DATEADD(m, -2, GETDATE())
WHILE @dt1 < =GETDATE() 
      BEGIN
       SELECT  @dt1 
       SET @dt1 = DATEADD(m, 1, @dt1)
END 