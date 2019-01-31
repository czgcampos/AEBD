import java.sql.*;
import java.util.Properties;
import java.lang.String ;
import java.util.Date ;
import java.util.logging.Level;
import java.util.logging.Logger;

public class Collector  {


    public static void main(String[] args){

        Connection sysConn = null;
        Connection monitorConn = null;


        try{
            Class.forName("oracle.jdbc.OracleDriver");

            // PDB ORCL SYS
            sysConn = DriverManager.getConnection(
                    "jdbc:oracle:thin:@//localhost:1521/orcl",
                    "sys as SYSDBA",
                    "oracle"
            );

            // PDB ORCL Monitor
            monitorConn = DriverManager.getConnection(
                    "jdbc:oracle:thin:@//localhost:1521/orcl",
                    "Monitor",
                    "monitor"
            );


            if (sysConn != null) {
                System.out.println("$ sys.orcl: Connected.");
            }
            else{
                System.out.println("$ sys.orcl: Failed connection.");
            }

            if (monitorConn != null) {
                System.out.println("$ Monitor.orcl: Connected.");
            }
            else{
                System.out.println("$ Monitor.orcl: Failed connection.");
            }


            while(true){

                // TABLESPACES
                System.out.println("$ TABLESPACES start.");
                PreparedStatement psmt;
                String getTablespaces = "SELECT " +
                        "ts.tablespace_name, " +
                        "\"File Count\", " +
                        "TRUNC(\"SIZE(MB)\", 2) \"Size(MB)\", " +
                        "TRUNC(fr.\"FREE(MB)\", 2) \"Free(MB)\", " +
                        "TRUNC(\"SIZE(MB)\" - \"FREE(MB)\", 2) \"Used(MB)\", " +
                        "df.\"MAX_EXT\" \"Max Ext(MB)\", " +
                        "(fr.\"FREE(MB)\" / df.\"SIZE(MB)\") * 100 \"% Free\" " +
                        "FROM " +
                        "(SELECT tablespace_name, " +
                        "SUM (bytes) / (1024 * 1024) \"FREE(MB)\" " +
                        "FROM dba_free_space " +
                        "GROUP BY tablespace_name) fr, " +
                        "(SELECT tablespace_name, SUM(bytes) / (1024 * 1024) \"SIZE(MB)\", COUNT(*) " +
                        "\"File Count\", SUM(maxbytes) / (1024 * 1024) \"MAX_EXT\" " +
                        "FROM dba_data_files " +
                        "GROUP BY tablespace_name) df, " +
                        "(SELECT tablespace_name " +
                        "FROM dba_tablespaces) ts " +
                        "WHERE fr.tablespace_name = df.tablespace_name (+) " +
                        "AND fr.tablespace_name = ts.tablespace_name (+) " +
                        "ORDER BY \"% Free\" desc";
                Statement getStmt = sysConn.createStatement();
                ResultSet resultSet = getStmt.executeQuery(getTablespaces);

                while(resultSet.next()) {

                    Statement monitorStmt = monitorConn.createStatement();
                    String updateQuery = "UPDATE \"MONITOR\".\"TABLESPACES\" " +
                            " SET \"filecount\" = " + Float.parseFloat(resultSet.getString("File Count")) +
                            "," + " \"size\" = " + resultSet.getString("Size(MB)") +
                            "," + " \"free\" = " + resultSet.getString("Free(MB)") +
                            "," + " \"used\" = " + resultSet.getString("Used(MB)") +
                            "," + " \"maxextend\" = " + resultSet.getString("Max Ext(MB)") +
                            "," + " \"percfree\" = " + resultSet.getString("% Free") +
                            "," + " \"timestamp\" = CURRENT_TIMESTAMP" +
                            " WHERE \"name\" = " + "'" + resultSet.getString("TABLESPACE_NAME") + "'";

                    int i=0;
                    // devolve o número queries afetadas
                    i = monitorStmt.executeUpdate(updateQuery);
                    // se não havia update a fazer (pq não constava inicialmente)
                    if(i==0) {

                        String insertQuery = "INSERT INTO \"MONITOR\".\"TABLESPACES\" " +
                                "(\"name\",\"filecount\",\"size\",\"free\",\"used\",\"maxextend\",\"percfree\",\"timestamp\") " +
                                "VALUES(?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)" ;
                        psmt = monitorConn.prepareStatement(insertQuery);

                        psmt.setString(1,resultSet.getString("TABLESPACE_NAME")) ;
                        psmt.setFloat(2,Float.parseFloat(resultSet.getString("File Count"))) ;
                        psmt.setFloat(3,Float.parseFloat(resultSet.getString("Size(MB)"))) ;
                        psmt.setFloat(4,Float.parseFloat(resultSet.getString("Free(MB)"))) ;
                        psmt.setFloat(5,Float.parseFloat(resultSet.getString("Used(MB)"))) ;
                        psmt.setFloat(6,Float.parseFloat(resultSet.getString("Max Ext(MB)"))) ;
                        psmt.setFloat(7,Float.parseFloat(resultSet.getString("% Free"))) ;
                        psmt.executeUpdate();
                        psmt.close();
                    }
                    monitorStmt.close();
                }
                System.out.println("$ TABLESPACES collected.");


                // DATAFILES
                System.out.println("$ DATAFILES start.");
                String getDatafiles = "SELECT file_name, file_id, tablespace_name, bytes, blocks, status," +
                                            " autoextensible, maxbytes, maxblocks, online_status" +
                                        " FROM dba_data_files" ;
                resultSet = getStmt.executeQuery(getDatafiles);
                while(resultSet.next()) {

                    Statement stmt1 = monitorConn.createStatement();

                    String updateDatafiles = "UPDATE \"MONITOR\".\"DATAFILES\" " +
                            " SET \"bytes\" = " + Float.parseFloat(resultSet.getString("BYTES")) +
                            "," + " \"blocks\" = " + Float.parseFloat(resultSet.getString("BLOCKS")) +
                            "," + " \"status\" = " + "'" + resultSet.getString("STATUS") + "'" +
                            "," + " \"autoextensible\" = " + "'" + resultSet.getString("AUTOEXTENSIBLE") + "'" +
                            "," + " \"maxbytes\" = " + Float.parseFloat(resultSet.getString("MAXBYTES")) +
                            "," + " \"maxblocks\" = " + Float.parseFloat(resultSet.getString("MAXBLOCKS")) +
                            "," + " \"onlinestatus\" = " + "'" + resultSet.getString("ONLINE_STATUS") + "'" +
                            "," + " \"timestamp\" = CURRENT_TIMESTAMP" +
                            " WHERE \"filename\" = " + "'" + resultSet.getString("FILE_NAME") + "'";

                    int i;
                    i = stmt1.executeUpdate(updateDatafiles);

                    if(i==0) {

                        String insertDatafiles = "INSERT INTO \"MONITOR\".\"DATAFILES\" "
                                + "(\"filename\",\"fileid\",\"tablename\",\"bytes\",\"blocks\"," +
                                "\"status\",\"autoextensible\"," +
                                "\"maxbytes\",\"maxblocks\"," +
                                "\"onlinestatus\"," +
                                "\"timestamp\") "
                                + "VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)" ;
                        psmt = monitorConn.prepareStatement(insertDatafiles) ;


                        psmt.setString(1,resultSet.getString("FILE_NAME")) ;
                        psmt.setFloat(2,Float.parseFloat(resultSet.getString("FILE_ID"))) ;
                        psmt.setString(3,resultSet.getString("TABLESPACE_NAME")) ;
                        psmt.setFloat(4,Float.parseFloat(resultSet.getString("BYTES"))) ;
                        psmt.setFloat(5,Float.parseFloat(resultSet.getString("BLOCKS"))) ;
                        psmt.setString(6,resultSet.getString("STATUS")) ;
                        psmt.setString(7,resultSet.getString("AUTOEXTENSIBLE")) ;
                        psmt.setFloat(8,Float.parseFloat(resultSet.getString("MAXBYTES"))) ;
                        psmt.setFloat(9,Float.parseFloat(resultSet.getString("MAXBLOCKS"))) ;
                        psmt.setString(10,resultSet.getString("ONLINE_STATUS")) ;
                        psmt.executeUpdate();
                        psmt.close();
                    }
                    stmt1.close();
                }
                System.out.println("$ DATAFILES collected.");



                // USERS
                System.out.println("$ USERS start.");
                String users = "SELECT USERNAME, ACCOUNT_STATUS, COMMON, EXPIRY_DATE, DEFAULT_TABLESPACE, TEMPORARY_TABLESPACE," +
                                    " PROFILE, CREATED" +
                                " FROM dba_users";
                resultSet = getStmt.executeQuery(users);

                while(resultSet.next()) {

                    Statement stmtUsers = monitorConn.createStatement();
                    String updateUser = " UPDATE \"MONITOR\".\"USERS\"" +
                            " SET \"accStatus\" = " + "'" + resultSet.getString("ACCOUNT_STATUS")+"'"+
                            "," + " \"common\" = " + "'" + resultSet.getString("COMMON") + "'" +
                            "," + " \"defaultTablespace\" = " + "'" + resultSet.getString("DEFAULT_TABLESPACE") + "'" +
                            "," + " \"tempTablespace\" = " + "'" + resultSet.getString("TEMPORARY_TABLESPACE") + "'" +
                            "," + " \"profile\" = " + "'" + resultSet.getString("PROFILE") + "'" +
                            "," + " \"timestamp\" = CURRENT_TIMESTAMP "  +
                            " WHERE \"username\" = " + "'" + resultSet.getString("USERNAME") + "'" ;

                    int i=0;
                    i = stmtUsers.executeUpdate(updateUser);

                    if(i==0) {

                        users = "INSERT INTO \"MONITOR\".\"USERS\""
                                + " (\"username\",\"accStatus\",\"common\",\"expiryDate\",\"defaultTablespace\",\"tempTablespace\"," +
                                "\"profile\",\"created\",\"timestamp\")"
                                + " VALUES(?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)" ;
                        psmt = monitorConn.prepareStatement(users) ;

                        psmt.setString(1,resultSet.getString("USERNAME")) ;
                        psmt.setString(2,resultSet.getString("ACCOUNT_STATUS")) ;
                        psmt.setString(3,resultSet.getString("COMMON")) ;
                        // caso não tenha expiry date
                        if(resultSet.getDate("EXPIRY_DATE") != null )
                            psmt.setDate(4,resultSet.getDate("EXPIRY_DATE")) ;
                        else
                            psmt.setNull(4, Types.TIMESTAMP);
                        psmt.setString(5,resultSet.getString("DEFAULT_TABLESPACE")) ;
                        psmt.setString(6,resultSet.getString("TEMPORARY_TABLESPACE")) ;
                        psmt.setString(7,resultSet.getString("PROFILE")) ;
                        psmt.setDate(8,resultSet.getDate("CREATED")) ;
                        
                        psmt.executeUpdate();
                        psmt.close();
                    }
                    stmtUsers.close();
                }
                System.out.println("$ USERS collected.");


                // SGA
                System.out.println("$ SGA start.");
                String sga = "select name, value from v$sga";

                resultSet = getStmt.executeQuery(sga);

                while(resultSet.next()) {

                    Statement sgaStmt = monitorConn.createStatement();
                    String updateSga = " UPDATE \"MONITOR\".\"SGA\"" +
                            " SET \"total\" = " + Float.parseFloat(resultSet.getString("VALUE")) +
                            "," + " \"timestamp\" = CURRENT_TIMESTAMP "  +
                            " WHERE \"name\" = " + "'" + resultSet.getString("NAME") + "'";

                    int i=0;
                    i = sgaStmt.executeUpdate(updateSga);

                    if(i==0) {

                        sga = "INSERT INTO \"MONITOR\".\"SGA\" (\"name\",\"total\",\"timestamp\") "
                                + "VALUES(?, ?, CURRENT_TIMESTAMP)" ;
                        psmt = monitorConn.prepareStatement(sga) ;

                        psmt.setString(1,resultSet.getString("NAME")) ;
                        psmt.setFloat(2,Float.parseFloat(resultSet.getString("VALUE")));
                        psmt.executeUpdate();
                        psmt.close();
                    }
                    sgaStmt.close();
                }
                System.out.println("$ SGA collected.");


                // PGA
                System.out.println("$ PGA start.");
                String pga = "SELECT name, value FROM v$pgastat WHERE NAME='total PGA inuse' OR NAME='total PGA allocated'";
                resultSet = getStmt.executeQuery(pga);

                while(resultSet.next()) {

                    Statement pgaStmt = monitorConn.createStatement();
                    String updatePga = " UPDATE \"MONITOR\".\"PGA\"" +
                            " SET \"usedPga\" = " + Float.parseFloat(resultSet.getString("VALUE")) +
                            "," + " \"timestamp\" = CURRENT_TIMESTAMP "  +
                            " WHERE \"name\" = " + "'" + resultSet.getString("NAME") + "'";

                    int i=0;
                    i = pgaStmt.executeUpdate(updatePga);

                    if(i==0) {

                        pga = "INSERT INTO \"MONITOR\".\"PGA\" (\"name\",\"usedPga\",\"timestamp\") "
                                + "VALUES(?, ?, CURRENT_TIMESTAMP)" ;
                        psmt = monitorConn.prepareStatement(pga) ;

                        psmt.setString(1,resultSet.getString("NAME")) ;
                        psmt.setFloat(2,Float.parseFloat(resultSet.getString("VALUE")));
                        psmt.executeUpdate();
                        psmt.close();
                    }
                    pgaStmt.close();
                }
                System.out.println("$ PGA collected.");



                // SESSIONS
                System.out.println("$ SESSIONS start.");
                String ses = "select sid, username, status, server, schemaname, osuser," +
                                    " machine, port, type, logon_time from v$session" +
                            " where username IS NOT NULL " ;

                resultSet = getStmt.executeQuery(ses);

                while(resultSet.next()) {

                        Statement sesStmt = monitorConn.createStatement();
                        String updateSes = " UPDATE \"MONITOR\".\"SESSIONS\"" +
                                " SET \"username\" = " + "'" + resultSet.getString("USERNAME") + "'" +
                                "," + " \"status\" = " + "'" + resultSet.getString("STATUS") + "'" +
                                "," + " \"server\" = " + "'" + resultSet.getString("SERVER") + "'" +
                                "," + " \"schemaName\" = " + "'" + resultSet.getString("SCHEMANAME") + "'" +
                                "," + " \"osUser\" = " + "'" + resultSet.getString("OSUSER") + "'" +
                                "," + " \"machine\" = " + "'" + resultSet.getString("MACHINE") + "'" +
                                "," + " \"port\" = " + resultSet.getString("PORT") +
                                "," + " \"type\" = " + "'" + resultSet.getString("TYPE") + "'" +
                                "," + " \"logonTime\" = " + "'" + resultSet.getDate("LOGON_TIME") + "'" +
                                "," + " \"timestamp\" = CURRENT_TIMESTAMP "  +
                                " WHERE \"sid\" = "  + resultSet.getString("SID");

                        int i=0;
                        i = sesStmt.executeUpdate(updateSes);

                        if(i==0) {

                            ses = "INSERT INTO \"MONITOR\".\"SESSIONS\""
                                    + " (\"sid\",\"username\",\"status\",\"server\",\"schemaName\",\"osUser\"," +
                                    "\"machine\",\"port\",\"type\",\"logonTime\",\"timestamp\")"
                                    + " VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)" ;
                            psmt = monitorConn.prepareStatement(ses) ;

                            psmt.setString(1,resultSet.getString("SID")) ;
                            psmt.setString(2,resultSet.getString("USERNAME")) ;
                            psmt.setString(3,resultSet.getString("STATUS")) ;
                            psmt.setString(4,resultSet.getString("SERVER")) ;
                            psmt.setString(5,resultSet.getString("SCHEMANAME")) ;
                            psmt.setString(6,resultSet.getString("OSUSER")) ;
                            psmt.setString(7,resultSet.getString("MACHINE")) ;
                            psmt.setString(8,resultSet.getString("PORT")) ;
                            psmt.setString(9,resultSet.getString("TYPE")) ;
                            psmt.setDate(10,resultSet.getDate("LOGON_TIME")) ;
                            psmt.executeUpdate();
                            psmt.close();
                        }
                    sesStmt.close();
                }
                System.out.println("$ SESSIONS collected.");



                // CPU
                System.out.println("$ CPU start.");
                String cpu = "SELECT USERNAME, SUM(CPU_USAGE) AS CPU_USAGE" +
                            " FROM (SELECT se.username, ROUND (value/100) AS CPU_USAGE" +
                                    " FROM v$session se, v$sesstat ss, v$statname st" +
                                        " WHERE ss.statistic# = st.statistic#" +
                                        " AND name LIKE  '%CPU used by this session%'" +
                                        " AND se.sid = ss.SID" +
                                        " AND se.username IS NOT NULL" +
                                    " ORDER BY value DESC" +
                            ")" +
                            " GROUP BY USERNAME";
                resultSet = getStmt.executeQuery(cpu);

                while(resultSet.next()) {

                    Statement cpuStmt = monitorConn.createStatement();
                    String updateCpu = " UPDATE \"MONITOR\".\"CPU\"" +
                            " SET \"cpuUsage\" = " + Float.parseFloat(resultSet.getString("CPU_USAGE")) +
                            "," + " \"timestamp\" = CURRENT_TIMESTAMP "  +
                            " WHERE \"username\" = " + "'" + resultSet.getString("USERNAME") + "'";

                    int i=0;
                    i = cpuStmt.executeUpdate(updateCpu);

                    if(i==0) {

                        cpu = "INSERT INTO \"MONITOR\".\"CPU\" (\"username\",\"cpuUsage\",\"timestamp\") "
                                + "VALUES(?, ?, CURRENT_TIMESTAMP)" ;
                        psmt = monitorConn.prepareStatement(cpu) ;

                        psmt.setString(1,resultSet.getString("USERNAME")) ;
                        psmt.setFloat(2,Float.parseFloat(resultSet.getString("CPU_USAGE")));
                        psmt.executeUpdate();
                        psmt.close();
                    }
                    cpuStmt.close();
                }
                System.out.println("$ CPU collected.");



                // CPU clean entries with more than 13 secs (some spare time for slow systems)
                System.out.println("$ CPU cleaning start.");
                String cpuInactive = "select \"username\", CURRENT_TIMESTAMP, CURRENT_TIMESTAMP - \"timestamp\"," +
                        " trunc((extract(second from CURRENT_TIMESTAMP - \"timestamp\")" +
                        " + 60 * (extract(minute from CURRENT_TIMESTAMP - \"timestamp\")" +
                        " + 60 * (extract(hour from CURRENT_TIMESTAMP - \"timestamp\")" +
                        " + 24 * (extract(day from CURRENT_TIMESTAMP - \"timestamp\") ))))) as seconds" +
                        " from \"MONITOR\".\"CPU\"";
                resultSet = getStmt.executeQuery(cpuInactive);

                while(resultSet.next()) {

                    // caso registo tenha mais de 13 secs de atraso
                    if(Float.parseFloat(resultSet.getString("seconds")) >= 13 ) {
                        System.out.println("DELETE " + resultSet.getString("USERNAME"));

                        // eliminar de CPU
                        cpuInactive = "DELETE FROM \"MONITOR\".\"CPU\" "
                                + "WHERE \"username\" = ?";
                        psmt = monitorConn.prepareStatement(cpuInactive);
                        psmt.setString(1, resultSet.getString("USERNAME"));
                        psmt.executeUpdate();

                        // eliminar de CPU_HIST
                        cpuInactive = "DELETE FROM \"MONITOR\".\"CPU_HIST\" "
                                + "WHERE \"username\" = ?";
                        psmt = monitorConn.prepareStatement(cpuInactive);
                        psmt.setString(1, resultSet.getString("USERNAME"));
                        psmt.executeUpdate();

                        psmt.close();
                    }
                }
                System.out.println("$ CPU cleaned.");

                // close sysConn
                getStmt.close();
                // esperar 10 segundos para repetir
                Thread.sleep(10000);
            }

        }catch(ClassNotFoundException e){
            System.out.println("Classe não existe ou não foi encontrada.: " + e) ;
        }catch(SQLException e){
            System.out.println("Erro no SQL:" + e) ;
        } catch (InterruptedException ex) {
            Logger.getLogger(Collector.class.getName()).log(Level.SEVERE, null, ex);
        }



    }

}
