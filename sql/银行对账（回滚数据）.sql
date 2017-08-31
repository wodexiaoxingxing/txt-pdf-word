USE [etest]
GO
/****** Object:  StoredProcedure [dbo].[COM_Gerenkehu_daoruyue_new]    Script Date: 03/06/2017 14:48:08 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER     PROCEDURE [dbo].[COM_Gerenkehu_daoruyue_new] 

AS
BEGIN 

/*
1 �˶Զ�˽������ˮ��ǿΰ���У�ǿΰ���У�

1.1 ����û��û�ж�������
1.2 ͨ������ �����ˮ���޸���������״̬��etest..UserMoney��


2 �˶ԶԹ�������ˮ���׽ݹ��У��׽ݽ��У�,���ָ��˿ͻ��ѷ���ֱ�ӻ��Թ�����
2.1 ����û��û�ж�������
2.2 ͨ������ �����ˮ���޸���������״̬��etest..qiyeMoney��

*/
 --��ʼ----------------------------------------------------------------------
DECLARE  @id     int
set   @Id =0
DECLARE  @username     varchar(50)
set   @username =''
DECLARE  @yhnum     varchar(50)
set   @yhnum =''
DECLARE  @lsdate     DATETIME
set   @lsdate =NULL
DECLARE  @adddate     DATETIME
set   @adddate =NULL

DECLARE  @userMoney  numeric(18,2)
set   @userMoney =0


DECLARE  @kehuNo     varchar(100)
set   @kehuNo =''
DECLARE  @kehuname     varchar(100)
set   @kehuname =''
DECLARE  @kehu_card     varchar(50)
set   @kehu_card =''

DECLARE  @nror     int
set   @nror =0


-- ǿΰ���� ǿΰ���� ����
DECLARE Roy_geren_bank CURSOR FOR
select  gr_bank.id,gr_bank.yhnum,gr_bank.username,gr_bank.usermoney,gr_bank.lsdate,gr.grno AS kehuNo,gr.kehuname AS kehuname,
gr.CardId --,GETDATE() AS adddate---gr_bank.adddate 
from etest..UserMoney AS gr_bank,geren_all_duizhang_bank_New AS gr
where 1=1
and DATEDIFF(m,adddate,getdate())=0
and dealsignal = 0 
AND shougongSignal = 0
AND feikehuSignal = 0 
AND buquedingSignal = 0
AND qitaSignal=0
and bank_num like replace(yhnum,'*','_') 
AND bank_username=username
order  by gr_bank.id asc

OPEN Roy_geren_bank
FETCH NEXT FROM Roy_geren_bank into @Id,@yhnum,@username,@userMoney,@lsdate,@kehuNo,@kehuname,@kehu_card--,@adddate
WHILE @@FETCH_STATUS=0
BEGIN 

--���뵱ǰ��ˮû�ж���
IF EXISTS ( SELECT  *
            FROM    etest..UserMoney
            WHERE   dealsignal = 0
                    AND shougongSignal = 0
                    AND buquedingSignal = 0
                    AND feikehuSignal = 0
                    AND qitaSignal=0
                    AND id = @id ) 
    BEGIN
        BEGIN TRAN UPDATE_liushui_usermoney
        SET @nror = 0 

-- �����ˮ��¼
        INSERT  INTO etest..Money_geren_NetOK
                ( Grno ,
                  gerenname ,
                  InMoney ,
                  outmoney ,
                  content ,
                  man ,
                  mandate---ת������
                )
        VALUES  ( @kehuNo ,
                  @kehuname ,
                  @userMoney ,
                  0 ,
                  '����ת�ˣ�ת������:'+isnull(convert(varchar(10),@lsdate,120),'')+',�ͻ�����:' + @yhnum ,
                  'ϵͳ' ,
                @lsdate--ת������
                  --  @adddate---��������
                )
        SET @nror = @nror + @@error
 

-- ����������ˮ״̬
        UPDATE  etest..UserMoney
        SET     dealsignal = 1 ,
                kehu_name = @kehuname +'('+@kehu_card+')',
                kehu_type = 1
        WHERE   id = @id
        SET @nror = @nror + @@error

        IF @nror <> 0 
            ROLLBACK TRAN UPDATE_liushui_usermoney
        ELSE 
            COMMIT TRAN UPDATE_liushui_usermoney
    END

FETCH NEXT FROM Roy_geren_bank  into @Id,@yhnum,@username,@userMoney,@lsdate,@kehuNo,@kehuname,@kehu_card
END 
CLOSE Roy_geren_bank
DEALLOCATE Roy_geren_bank

 

 -- �׽ݹ��� �׽ݽ���
DECLARE Roy_qiye_bank CURSOR FOR
select  qy_bank.id,qy_bank.yhnum,qy_bank.username,qy_bank.usermoney,qy_bank.lsdate,gr.grno,gr.kehuname,gr.CardId --,GETDATE() AS adddate --,qy_bank.adddate
 from etest..qiyeMoney AS qy_bank,geren_all_duizhang_bank_New AS gr
where 1=1
and DATEDIFF(m, qy_bank.adddate,getdate())=0
and dealsignal = 0 
AND shougongSignal = 0
AND feikehuSignal = 0 
AND buquedingSignal = 0 
AND qitaSignal=0
AND yhnum = gr.bank_num
AND username=gr.bank_username
order  by qy_bank.id asc

OPEN Roy_qiye_bank
FETCH NEXT FROM Roy_qiye_bank into @Id,@yhnum,@username,@userMoney,@lsdate,@kehuNo,@kehuname,@kehu_card--,@adddate
WHILE @@FETCH_STATUS=0
BEGIN 

--���뵱ǰ��ˮû�ж���
IF EXISTS ( SELECT  *
            FROM    etest..qiyeMoney
            WHERE   dealsignal = 0
                    AND shougongSignal = 0
                    AND buquedingSignal = 0
                    AND feikehuSignal = 0
                    AND qitaSignal=0
                    AND id = @id ) 
        BEGIN
        BEGIN TRAN UPDATE_liushui_qiyemoney
        SET @nror = 0       

-- �����ˮ��¼
        INSERT  INTO etest..Money_geren_NetOK
                ( Grno ,
                  gerenname ,
                  InMoney ,
                  outmoney ,
                  content ,
                  man ,
                  mandate--ת������
                )
        VALUES  ( @kehuNo ,
                  @kehuname ,
                  @userMoney ,
                  0 ,
                 '����ת�ˣ�ת������:'+isnull(convert(varchar(10),@lsdate,120),'')+',�ͻ�����:' + + @yhnum ,
                  'ϵͳ' ,
                  @lsdate--ת������
                  --  @adddate---��������
                )
        SET @nror = @nror + @@error
 

-- ����������ˮ״̬
        UPDATE  etest..qiyeMoney
        SET     dealsignal = 1 ,
                kehu_name = @kehuname +'('+@kehu_card+')',
                kehu_type = 1
        WHERE   id = @id
        SET @nror = @nror + @@error

        IF @nror <> 0 
            ROLLBACK TRAN UPDATE_liushui_qiyemoney
        ELSE 
            COMMIT TRAN UPDATE_liushui_qiyemoney
    END 

FETCH NEXT FROM Roy_qiye_bank into @Id,@yhnum,@username,@userMoney,@lsdate,@kehuNo,@kehuname,@kehu_card
END 

CLOSE Roy_qiye_bank
DEALLOCATE Roy_qiye_bank


end

