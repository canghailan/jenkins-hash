import numpy as np

def jenkins_hash(key):
    with np.errstate(over='ignore', under='ignore'):
        key = np.uint64(key)
        key = np.left_shift(key, np.uint64(21)) - key - np.uint64(1)
        key = np.bitwise_xor(key, np.right_shift(key, np.uint64(24)))
        key = key * np.uint64(265)
        key = np.bitwise_xor(key, np.right_shift(key, np.uint64(14)))
        key = key * np.uint64(21)
        key = np.bitwise_xor(key, np.right_shift(key, np.uint64(28)))
        key = key + np.left_shift(key, np.uint64(31))
        return key


def jenkins_inverse_hash(key):
    with np.errstate(over='ignore', under='ignore'):
        key = np.uint64(key)
        # Invert key = key + (key << 31)
        tmp = key-np.left_shift(key, np.uint64(31))
        key = key-np.left_shift(tmp, np.uint64(31))

        # Invert key = key ^ (key >> 28)
        tmp = np.bitwise_xor(key, np.right_shift(key, np.uint64(28)))
        key = np.bitwise_xor(key, np.right_shift(tmp, np.uint64(28)))

        # Invert key *= 21
        key *= np.uint64(14933078535860113213)

        # Invert key = key ^ (key >> 14)
        tmp = np.bitwise_xor(key, np.right_shift(key, np.uint64(14)))
        tmp = np.bitwise_xor(key, np.right_shift(tmp, np.uint64(14)))
        tmp = np.bitwise_xor(key, np.right_shift(tmp, np.uint64(14)))
        key = np.bitwise_xor(key, np.right_shift(tmp, np.uint64(14)))

        # Invert key *= 265
        key *= np.uint64(15244667743933553977)

        # Invert key = key ^ (key >> 24)
        tmp = np.bitwise_xor(key, np.right_shift(key, np.uint64(24)))
        key = np.bitwise_xor(key, np.right_shift(tmp, np.uint64(24)))

        # Invert key = (~key) + (key << 21)
        tmp = np.invert(key)
        tmp = np.invert(key-np.left_shift(tmp, np.uint64(21)))
        tmp = np.invert(key-np.left_shift(tmp, np.uint64(21)))
        key = np.invert(key-np.left_shift(tmp, np.uint64(21)))

        return key


def jtoh(j):
    if j is None:
        return None
    return np.base_repr(jenkins_hash(j), np.uint64(32)).lower()


def htoj(h):
    if h is None or h == '':
        return None
    return np.asscalar(np.int64(jenkins_inverse_hash(int(h, 32))))