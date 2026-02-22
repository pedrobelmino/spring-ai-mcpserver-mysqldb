package br.com.pedrobemino.mcpserver.mysqldb;

import org.springframework.ai.support.ToolCallbacks;
import org.springframework.ai.tool.ToolCallback;
import org.springframework.ai.tool.ToolCallbackProvider;
import org.springframework.ai.tool.method.MethodToolCallbackProvider;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

import java.util.List;

@SpringBootApplication
public class McpServerApplication {

	public static void main(String[] args) {
		SpringApplication.run(McpServerApplication.class, args);
	}

	@Bean
	public ToolCallbackProvider databaseMetamodelTools(MetamodelToolsService weatherService) {
		return MethodToolCallbackProvider.builder().toolObjects(weatherService).build();
	}


	@Bean
	public List<ToolCallback> databaseMetamodelToolsCallbacks(MetamodelToolsService weatherService) {
		return List.of(ToolCallbacks.from(weatherService));
	}


}