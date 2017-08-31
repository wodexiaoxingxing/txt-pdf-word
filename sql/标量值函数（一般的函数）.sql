USE [etest_zongbu]
GO
/****** Object:  UserDefinedFunction [dbo].[Fn_Product_Effective]    Script Date: 03/06/2017 14:34:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
˵����
������ҵ����Ч����     XX>= ��Ա�·�   XX < ��Ա�·�
һ����ҵ����Ч����     XX>= ��Ա�·�   XX < ��Ա����·�+1

-- �жϵ�ǰ�·�(@CurrDate),��Ʒ�Ƿ���Ч
����ֵ��
1  ��Чҵ��
-2 ��ֹҵ�� 
2  δ��ҵ��
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
      --һ���Բ�Ʒ
      IF @ProType = 1
      SET @B_Month = DATEDIFF(m, '2000-01-01', ISNULL(@zy_Completedate,'2050-01-01'))+1


      --���ڲ�Ʒ
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







