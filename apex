1. PULL IMAGE
    Efetuar o download da imagem Oracle Database 12c
    Link da imagem: https://hub.docker.com/_/oracle-database-enterprise-edition
    Executar o comando para baixar a imagem no docker 
    $ docker pull store/oracle/database-enterprise:12.2.0.1
    
    The default password to connect to the database with sys user is Oradoc_db1. 
    If you wanted to change: SQL> alter user sys identified by <new-password>;

*******************************************************************************
2. CRIAR CONTAINER
#   Informando parametros de volume e porta.
    $ docker run -it --rm --name OracleDB -v c:\Containers\:/Containers -p 1521:1521 -p 8081:8081 store/oracle/database-enterprise:12.2.0.1
    
    2.1.	EXECUTANDO CONTAINER
          $ docker exec -it OracleDB bash

*******************************************************************************

3. APEX 5.1.1
#    Download: https://download.oracle.com/otn/java/appexpress/apex_5.1.1_en.zip?AuthParam=1588192760_307401025dc9f60f304305fa2289fdae
#              https://www.oracle.com/tools/downloads/apex-v51-downloads.html
#
#    Descompacte e Mude o diretório para o diretório que contém o software APEX descompactado.
      $ cd /
      $ cp -r /Containers/apex $ORACLE_HOME/

*******************************************************************************

4. INSTALANDO APEX
  
  4.1.  Conecte-se ao SQL * Plus como usuário do SYS e execute o script "apexins.sql", especificando os nomes relevantes do espaço de tabela e o URL da imagem.
    
          $ cd $ORACLE_HOME/apex
          $ sqlplus / as sysdba
          
#        @ apexins.sql tablespace_apex tablespace_files tablespace_temp imagens
          SQL>  @apexins.sql APEX_DATA APEX_FILES TEMP /i/
    
#         If you get the error "unknown tablespace", execute these 2 commands:
#         Error: The tablespace APEX_DATA does not exist.
    
          SQL> CREATE TABLESPACE APEX_DATA LOGGING DATAFILE '/u01/datafiles/apex_data' SIZE 500M AUTOEXTEND ON NEXT 500M EXTENT MANAGEMENT LOCAL;
          SQL> CREATE TABLESPACE APEX_FILES LOGGING DATAFILE '/u01/datafiles/apex_files' SIZE 500M AUTOEXTEND ON NEXT 500M EXTENT MANAGEMENT LOCAL;
   
-------------------------------------------------------------------------------  
  4.2.  Depois de concluído, altere a senha do administrador executando os scripts "apxchpwd.sql" como o usuário SYS.
  
          SQL> @apxchpwd.sql 

-------------------------------------------------------------------------------
  4.3.  Configuração incorporada do gateway PL / SQL (EPG) para usar o Gateway PL / SQL Incorporado (EPG) para fazer frente ao APEX
          
          SQL> @apex_epg_config.sql $ORACLE_HOME


-------------------------------------------------------------------------------  
  4.4.  Unlock anonymous account
        # Ctrl + Shift -- para add mais linhas
        # / + Enter para executar.
     
          SQL>  DECLARE
                l_passwd VARCHAR2(40);
                BEGIN
                  l_passwd := DBMS_RANDOM.string('a',10) || DBMS_RANDOM.string('x',10) || '1#';
                  EXECUTE IMMEDIATE 'ALTER USER anonymous IDENTIFIED BY ' || l_passwd || ' ACCOUNT UNLOCK CONTAINER=ALL';
                END;
                /

-------------------------------------------------------------------------------
  4.5.  Alterar porta de execução do APEX, http://localhost:8081/apex
          SQL> SELECT DBMS_XDB.gethttpport FROM DUAL;
          # if 0, set port
          SQL> EXEC DBMS_XDB.sethttpport(8081);

          http://localhost:8081/apex
              workspace   INTERNAL
              user        ADMIN
              password    <a mesma do passo 4.2>


*******************************************************************************
Guides:
  https://oracle-base.com/articles/misc/oracle-application-express-apex-installation#installation

  https://docs.oracle.com/en/database/oracle/application-express/19.1/htmig/downloading-installing-Oracle-AE.html#GUID-93638EC4-5278-421B-9C19-BB68F9B31C40

  https://confluence.csgicorp.com/pages/viewpage.action?spaceKey=WP&title=APEX+Install
  
  https://gist.github.com/thgfrzm/8d4f0bcd5296b279c8012e3da90cfe88
