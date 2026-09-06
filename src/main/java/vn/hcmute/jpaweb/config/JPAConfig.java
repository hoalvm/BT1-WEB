package vn.hcmute.jpaweb.config;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;

import java.util.HashMap;
import java.util.Map;

/**
 * Creates one application-wide EntityManagerFactory.
 * EntityManager instances are short-lived and must be closed by their callers.
 */
public final class JPAConfig {

    private static final String PERSISTENCE_UNIT_NAME = "jpa-hibernate-mysql";
    private static final String DB_PASSWORD_ENV = "JPAWEB_DB_PASSWORD";
    private static final EntityManagerFactory ENTITY_MANAGER_FACTORY =
            createEntityManagerFactory();

    private JPAConfig() {
    }

    public static EntityManager getEntityManager() {
        if (!ENTITY_MANAGER_FACTORY.isOpen()) {
            throw new IllegalStateException("EntityManagerFactory has already been closed");
        }
        return ENTITY_MANAGER_FACTORY.createEntityManager();
    }

    public static void close() {
        if (ENTITY_MANAGER_FACTORY.isOpen()) {
            ENTITY_MANAGER_FACTORY.close();
        }
    }

    private static EntityManagerFactory createEntityManagerFactory() {
        String password = System.getenv(DB_PASSWORD_ENV);
        if (password == null || password.isBlank()) {
            return Persistence.createEntityManagerFactory(PERSISTENCE_UNIT_NAME);
        }

        Map<String, Object> overrides = new HashMap<>();
        overrides.put("jakarta.persistence.jdbc.password", password);
        return Persistence.createEntityManagerFactory(PERSISTENCE_UNIT_NAME, overrides);
    }
}
