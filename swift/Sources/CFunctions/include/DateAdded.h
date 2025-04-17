#ifndef Header_h
#define Header_h
#include <sys/attr.h>

int foo_bar(int input);

/// Get kMDItemDateAdded of path.
///
/// - Returns:
///   - 0 on success
///   - 1 if a system call failed: check errno
///   - 2 if something else went wrong
int get_date_added(const char* path, struct timespec * out);

/// Set kMDItemDateAdded of path.
///
/// - Returns:
///   - 0 on success
///   - 1 if a system call failed: check errno
int set_date_added(const char* path, struct timespec in);

#endif /* Header_h */
