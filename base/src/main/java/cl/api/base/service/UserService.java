package cl.api.base.service;

import cl.api.base.domain.User;
import cl.api.base.dto.request.UserUpdateRequest;
import cl.api.base.dto.response.PageResponse;
import cl.api.base.dto.response.UserResponse;
import cl.api.base.exception.ResourceNotFoundException;
import cl.api.base.mapper.UserMapper;
import cl.api.base.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
public class UserService {

    private final UserRepository userRepository;
    private final UserMapper userMapper;

    @Transactional(readOnly = true)
    public PageResponse<UserResponse> getAllUsers(Pageable pageable) {
        log.debug("Getting all users with pagination: page={}, size={}", pageable.getPageNumber(), pageable.getPageSize());

        Page<User> userPage = userRepository.findAllActive(pageable);
        Page<UserResponse> responsePage = userMapper.toResponsePage(userPage);

        return PageResponse.<UserResponse>builder()
                .content(responsePage.getContent())
                .page(responsePage.getNumber())
                .size(responsePage.getSize())
                .totalElements(responsePage.getTotalElements())
                .totalPages(responsePage.getTotalPages())
                .first(responsePage.isFirst())
                .last(responsePage.isLast())
                .empty(responsePage.isEmpty())
                .build();
    }

    @Transactional(readOnly = true)
    public UserResponse getUserById(Long id) {
        log.debug("Getting user by id: {}", id);

        User user = userRepository.findActiveById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", id));

        return userMapper.toResponse(user);
    }

    @Transactional(readOnly = true)
    public UserResponse getUserByUsername(String username) {
        log.debug("Getting user by username: {}", username);

        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new ResourceNotFoundException("User", "username", username));

        return userMapper.toResponse(user);
    }

    @Transactional
    public UserResponse updateUser(Long id, UserUpdateRequest request) {
        log.info("Updating user with id: {}", id);

        User user = userRepository.findActiveById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", id));

        userMapper.updateEntity(user, request);
        User updatedUser = userRepository.save(user);

        log.info("User updated successfully: {}", updatedUser.getUsername());
        return userMapper.toResponse(updatedUser);
    }

    @Transactional
    public void deleteUser(Long id) {
        log.info("Soft deleting user with id: {}", id);

        User user = userRepository.findActiveById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", id));

        user.setDeleted(true);
        user.setEnabled(false);
        userRepository.save(user);

        log.info("User soft deleted successfully: {}", user.getUsername());
    }
}

