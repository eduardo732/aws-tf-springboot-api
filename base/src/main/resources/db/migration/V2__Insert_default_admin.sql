-- Insert default admin user
-- Password: Admin123! (BCrypt encoded)
INSERT INTO users (username, email, password, first_name, last_name, enabled, account_non_expired, account_non_locked, credentials_non_expired, deleted)
VALUES ('admin', 'admin@api.cl', '$2a$10$KzGnIqKAr8LwC7jLUEXDPuP5E9bDDBFQGqMq4DjSj.NjKmFkqvG4a', 'Admin', 'User', TRUE, TRUE, TRUE, TRUE, FALSE);

-- Assign ADMIN role to admin user
INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id
FROM users u, roles r
WHERE u.username = 'admin' AND r.name = 'ROLE_ADMIN';

