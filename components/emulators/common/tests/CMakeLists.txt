enable_testing()
# Common tests

# # Test for emulator
add_executable(test_initialization test_emulator.cpp)
target_link_libraries(test_initialization PRIVATE emulator_common Catch2)
target_compile_definitions(test_initialization PRIVATE TEST_DATA_DIR="${CMAKE_CURRENT_SOURCE_DIR}/input-data")
add_test(NAME emulator_initialization COMMAND test_initialization)

add_executable(test_emulator_coupling test_emulator_coupling.cpp)
target_link_libraries(test_emulator_coupling PRIVATE emulator_common Catch2)
target_compile_definitions(test_emulator_coupling PRIVATE TEST_DATA_DIR="${CMAKE_CURRENT_SOURCE_DIR}/input-data")
add_test(NAME emulator_coupling COMMAND test_emulator_coupling)
#
# # Test for InferenceConfig and utilities
# add_executable(test_inference_config test_inference_config.cpp)
# target_link_libraries(test_inference_config PRIVATE emulator_common Catch2)
# add_test(NAME inference_config_tests COMMAND test_inference_config)
#
# # Test for StubBackend
# add_executable(test_inference_stub_backend test_inference_stub_backend.cpp)
# target_link_libraries(test_inference_stub_backend PRIVATE emulator_common Catch2)
# add_test(NAME inference_stub_backend_tests COMMAND test_inference_stub_backend)

add_executable(test_emulator_config test_emulator_config.cpp)
target_link_libraries(test_emulator_config PRIVATE emulator_common Catch2)
target_compile_definitions(test_emulator_config PRIVATE TEST_DATA_DIR="${CMAKE_CURRENT_SOURCE_DIR}/input-data")
add_test(NAME test_emulator_config COMMAND test_emulator_config)



