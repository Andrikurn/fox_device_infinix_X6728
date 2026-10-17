//===----------------------------------------------------------------------===//
// libc++ __libcpp_verbose_abort shim
// Target symbol: _ZNSt3__122__libcpp_verbose_abortEPKcz
// Based on LLVM's libcxx/src/verbose_abort.cpp
//===----------------------------------------------------------------------===//

#include <cstdarg>
#include <cstdio>
#include <cstdlib>
#include <syslog.h>

extern "C" void android_set_abort_message(const char* msg);

namespace std {
inline namespace __1 {

__attribute__((visibility("default"), weak))
void __libcpp_verbose_abort(char const* format, ...) noexcept {
  {
    va_list list;
    va_start(list, format);
    std::vfprintf(stderr, format, list);
    va_end(list);
  }

  char* buffer = nullptr;
  va_list list;
  va_start(list, format);

  if (vasprintf(&buffer, format, list) != -1 && buffer != nullptr) {
    android_set_abort_message(buffer);
    openlog("libc++", 0, 0);
    syslog(LOG_CRIT, "%s", buffer);
    closelog();
  }

  va_end(list);
  std::abort();
}

}
}
