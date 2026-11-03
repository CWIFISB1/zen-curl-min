# 覆盖 curl 用的 FindOpenSSL：
# BoringSSL 只产出 libssl.a / libcrypto.a，没有 CMake config 包，
# 所以这里手工定义 OpenSSL::SSL / OpenSSL::Crypto 两个 IMPORTED target。
# 路径由 -DBORINGSSL_DIR=... 传入。

set(_BS "${BORINGSSL_DIR}")
if(NOT EXISTS "${_BS}/build/ssl/libssl.a")
  message(FATAL_ERROR "libssl.a 不存在: ${_BS}/build/ssl/libssl.a")
endif()
if(NOT EXISTS "${_BS}/build/crypto/libcrypto.a")
  message(FATAL_ERROR "libcrypto.a 不存在: ${_BS}/build/crypto/libcrypto.a")
endif()

set(OPENSSL_FOUND TRUE)
set(OPENSSL_VERSION "1.1.1")
set(OPENSSL_INCLUDE_DIR "${_BS}/include")
set(OPENSSL_SSL_LIBRARY "${_BS}/build/ssl/libssl.a")
set(OPENSSL_CRYPTO_LIBRARY "${_BS}/build/crypto/libcrypto.a")
set(OPENSSL_LIBRARIES "${OPENSSL_SSL_LIBRARY}" "${OPENSSL_CRYPTO_LIBRARY}")

if(NOT TARGET OpenSSL::SSL)
  add_library(OpenSSL::SSL UNKNOWN IMPORTED)
  set_target_properties(OpenSSL::SSL PROPERTIES
    IMPORTED_LOCATION "${OPENSSL_SSL_LIBRARY}"
    INTERFACE_INCLUDE_DIRECTORIES "${OPENSSL_INCLUDE_DIR}"
    INTERFACE_LINK_LIBRARIES "OpenSSL::Crypto")
endif()

if(NOT TARGET OpenSSL::Crypto)
  add_library(OpenSSL::Crypto UNKNOWN IMPORTED)
  set_target_properties(OpenSSL::Crypto PROPERTIES
    IMPORTED_LOCATION "${OPENSSL_CRYPTO_LIBRARY}"
    INTERFACE_INCLUDE_DIRECTORIES "${OPENSSL_INCLUDE_DIR}")
endif()

message(STATUS "FindOpenSSL override -> BoringSSL at ${_BS}")