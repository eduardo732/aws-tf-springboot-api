package cl.api.base;

import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.core.env.Environment;

import java.net.InetAddress;
import java.net.UnknownHostException;

/**
 * Main Spring Boot Application Class
 *
 * Professional RESTful API with:
 * - JWT Authentication & Refresh Tokens
 * - PostgreSQL Database
 * - Flyway Migrations
 * - OpenAPI/Swagger Documentation
 * - Global Exception Handling
 * - Role-Based Access Control
 *
 * @author Base API Team
 * @version 1.0.0
 */
@SpringBootApplication
@Slf4j
public class BaseApplication {

	public static void main(String[] args) {
		SpringApplication app = new SpringApplication(BaseApplication.class);
		Environment env = app.run(args).getEnvironment();
		logApplicationStartup(env);
	}

	private static void logApplicationStartup(Environment env) {
		String protocol = "http";
		String serverPort = env.getProperty("server.port");
		String contextPath = env.getProperty("server.servlet.context-path");
		if (contextPath == null || contextPath.isBlank()) {
			contextPath = "/";
		}
		String hostAddress = "localhost";
		try {
			hostAddress = InetAddress.getLocalHost().getHostAddress();
		} catch (UnknownHostException e) {
			log.warn("The host name could not be determined, using `localhost` as fallback");
		}

		log.info("""
				
				----------------------------------------------------------
				Application '{}' is running! Access URLs:
				Local:      {}://localhost:{}{}
				External:   {}://{}:{}{}
				Profile(s): {}
				Swagger:    {}://localhost:{}{}/swagger-ui.html
				----------------------------------------------------------
				""",
				env.getProperty("spring.application.name"),
				protocol, serverPort, contextPath,
				protocol, hostAddress, serverPort, contextPath,
				env.getActiveProfiles().length == 0 ? env.getDefaultProfiles() : env.getActiveProfiles(),
				protocol, serverPort, contextPath);
	}
}
