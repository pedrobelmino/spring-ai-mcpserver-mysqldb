package br.com.pedrobemino.mcpserver.mysqldb;

import org.springframework.ai.tool.annotation.Tool;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.sql.SQLException;

@Service
public class MetamodelToolsService {

    private final JdbcTemplate jdbcTemplate;

    public MetamodelToolsService(DataSource dataSource) {
        this.jdbcTemplate = new JdbcTemplate(dataSource);
    }

    @Tool(description = "Get Database Metamodel")
    public String getMetamodel() {
        try {
            DataSource ds = jdbcTemplate.getDataSource();
            if (ds == null) {
                throw new RuntimeException("DataSource is null");
            }

            try (Connection conn = ds.getConnection()) {
                DatabaseMetaData metaData = conn.getMetaData();
                try (ResultSet tables = metaData.getTables(null, null, "%", new String[]{"TABLE"})) {
                    StringBuilder metamodel = new StringBuilder();
                    while (tables.next()) {
                        String tableName = tables.getString("TABLE_NAME");
                        metamodel.append("Table: ").append(tableName).append("\n");

                        try (ResultSet columns = metaData.getColumns(null, null, tableName, "%")) {
                            while (columns.next()) {
                                String columnName = columns.getString("COLUMN_NAME");
                                String columnType = columns.getString("TYPE_NAME");
                                int columnSize = columns.getInt("COLUMN_SIZE");

                                metamodel.append("\tColumn: ").append(columnName)
                                        .append(", Type: ").append(columnType)
                                        .append(", Size: ").append(columnSize)
                                        .append("\n");
                            }
                        }
                    }
                    return metamodel.toString();
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }
}
