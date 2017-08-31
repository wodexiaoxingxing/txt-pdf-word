USE [etest_zongbu]
GO
/****** Object:  UserDefinedFunction [dbo].[Fn_Product_Effective]    Script Date: 03/06/2017 14:34:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
说明：
周期性业务有效规则     XX>= 增员月份   XX < 减员月份
一次性业务有效规则     XX>= 增员月份   XX < 增员完成月份+1

-- 判断当前月份(@CurrDate),产品是否有效
返回值：
1  有效业务
-2 终止业务 
2  未来业务
*/

ALTER FUNCTION [dbo].[Fn_Product_Effective]
      (
        @ProType INT ,
        @zy_Stardate DATETIME ,
        @zy_Completedate DATETIME ,
        @jy_Stardate DATETIME ,
        @jy_Completedate DATETIME ,
        @CurrDate DATETIME
      )
RETURNS INT
with SCHEMABINDING  

AS 
    BEGIN 
      DECLARE @reint INT  = 0
      
      IF @zy_Stardate IS NULL OR @CurrDate IS NULL OR @ProType NOT IN (1,2)
         RETURN NULL
         
         
      DECLARE @CurrDate_Month INT = DATEDIFF(m, '2000-01-01', @CurrDate)
      DECLARE @A_Month INT = DATEDIFF(m, '2000-01-01', @zy_Stardate)
      DECLARE @B_Month INT = 0
      --一次性产品
      IF @ProType = 1
      SET @B_Month = DATEDIFF(m, '2000-01-01', ISNULL(@zy_Completedate,'2050-01-01'))+1


      --周期产品
      IF @ProType = 2
      SET @B_Month = DATEDIFF(m, '2000-01-01', ISNULL(@jy_Stardate,'2050-01-01'))

  
      IF @CurrDate_Month <@A_Month
      SET @reint=2 
      
      IF @CurrDate_Month >=@A_Month AND @CurrDate_Month<@B_Month
      SET @reint=1
      
      IF @CurrDate_Month >=@B_Month
      SET @reint=-2 

      RETURN @reint

    END







