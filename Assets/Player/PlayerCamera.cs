using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using static UnityEngine.InputSystem.DefaultInputActions;

public class PlayerCamera : MonoBehaviour
{
    [Header("General")]
    [SerializeField] private Camera _camera;
    [Space]
    [SerializeField] private float _moveSpeed = 10f;
    [SerializeField] private float _rotateSpeed = 10f;
    [SerializeField] private Vector2 _pitchMax = new Vector2(-30f, 30f);

    private PlayerInput _playerActions;
    private InputAction _moveAction;
    private InputAction _moveUpAction;
    private InputAction _moveDownAction;
    private InputAction _moveSlowAction;
    private InputAction _lookAction;

    private bool _canRotate = false;
    private float _cameraPitch = 0f;

    private void Start()
    {
        // Input
        _playerActions = new PlayerInput();
        _playerActions.Movement.Enable();

        _moveAction = _playerActions.Movement.Move;
        _moveUpAction = _playerActions.Movement.MoveUp;
        _moveDownAction = _playerActions.Movement.MoveDown;
        _moveSlowAction = _playerActions.Movement.Slow;

        _playerActions.Movement.StartLook.started += StartLook;
        _playerActions.Movement.StartLook.canceled += EndLook;
        _lookAction = _playerActions.Movement.Look;
    }

    private void FixedUpdate()
    {
        Move();
        Rotate();
    }
    private void Move()
    {
        // Horizontal
        Vector2 moveInput = _moveAction.ReadValue<Vector2>();
        Vector3 moveDirection = transform.forward * moveInput.y + transform.right * moveInput.x;

        // Vertical
        bool goUp = 0 < _moveUpAction.ReadValue<float>();
        if (goUp) moveDirection += Vector3.up;
        bool goDown = 0 < _moveDownAction.ReadValue<float>();
        if (goDown) moveDirection += Vector3.down;

        // Add movement
        float movementSpeed = _moveSpeed * Time.deltaTime;
        bool slowDown = 0 < _moveSlowAction.ReadValue<float>();
        if (slowDown) movementSpeed *= 0.5f;

        Vector3 deltaMovement = moveDirection * movementSpeed;
        transform.position += deltaMovement;
    }
    private void Rotate()
    {
        if (!_canRotate) return;

        Vector2 deltaPos = _lookAction.ReadValue<Vector2>();
        float rotateSpeed = _rotateSpeed * Time.deltaTime;

        // Yaw
        Vector3 eulerAngles = transform.eulerAngles;
        eulerAngles.y += deltaPos.x * rotateSpeed;

        // Pitch
        _cameraPitch += deltaPos.y * rotateSpeed * -1; // Reverse Y
        _cameraPitch = Mathf.Clamp(_cameraPitch, _pitchMax.x, _pitchMax.y);
        eulerAngles.x = _cameraPitch;

        // Set rotation
        transform.eulerAngles = eulerAngles;
    }

    private void StartLook(InputAction.CallbackContext obj)
    {
        _canRotate = true;

        // Hide & lock cursor
        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;
    }
    private void EndLook(InputAction.CallbackContext obj)
    {
        _canRotate = false;

        // Visible & free cursor
        Cursor.lockState = CursorLockMode.None;
        Cursor.visible = true;
    }
}
