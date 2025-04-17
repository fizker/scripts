#include <stdlib.h>
#include <string.h>
#include <sys/attr.h>
#include <unistd.h>

int foo_bar(int input) {
	return input + 3;
}

/// Get kMDItemDateAdded of path.
///
/// - Returns:
///   - 0 on success
///   - 1 if a system call failed: check errno
///   - 2 if something else went wrong
int get_date_added(const char* path, struct timespec * out) {
    attrgroup_t request_attrs = ATTR_CMN_RETURNED_ATTRS | ATTR_CMN_ADDEDTIME;

    struct attrlist request;
    memset(&request, 0, sizeof(request));
    request.bitmapcount = ATTR_BIT_MAP_COUNT;
    request.commonattr = request_attrs;

    typedef struct {
        u_int32_t length;
        attribute_set_t returned;
        struct timespec added;
    } __attribute__((aligned(4), packed)) response_buf_t;

    response_buf_t response;

    int err = getattrlist(path, &request, &response, sizeof(response), 0);
    if (err != 0) {
        return 1;
    }
    if (response.length != sizeof(response)) {
        // Need a different-sized buffer; but provided one of exactly required
        // size?!
        return 2;
    }
    if (response.returned.commonattr != request_attrs) {
        // Didn’t get back all requested common attributes
        return 2;
    }

    out->tv_sec = response.added.tv_sec;
    out->tv_nsec = response.added.tv_nsec;

    return 0;
}

/// Set kMDItemDateAdded of path.
///
/// - Returns:
///   - 0 on success
///   - 1 if a system call failed: check errno
int set_date_added(const char* path, struct timespec in) {
    attrgroup_t request_attrs = ATTR_CMN_ADDEDTIME;

    struct attrlist request;
    memset(&request, 0, sizeof(request));
    request.bitmapcount = ATTR_BIT_MAP_COUNT;
    request.commonattr = request_attrs;

    typedef struct {
        struct timespec added;
    } __attribute__((aligned(4), packed)) request_buf_t;

    request_buf_t request_buf;
    request_buf.added.tv_sec = in.tv_sec;
    request_buf.added.tv_nsec = in.tv_nsec;

    int err = setattrlist(path, &request, &request_buf, sizeof(request_buf), 0);
    if (err != 0) {
        return 1;
    }

    return 0;
}
