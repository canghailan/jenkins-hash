public class JenkinsHash {
    public static Long ofNullable(String key) {
        return (key == null || key.isEmpty()) ? null : of(key);
    }

    public static long of(String key) {
        return of(Long.parseUnsignedLong(key, 32));
    }

    public static long of(long key) {
        long tmp;

        // Invert key = key + (key << 31)
        tmp = key - (key << 31);
        key = key - (tmp << 31);

        // Invert key = key ^ (key >> 28)
        tmp = key ^ key >>> 28;
        key = key ^ tmp >>> 28;

        // Invert key *= 21
        key *= 0xcf3cf3cf3cf3cf3dL;

        // Invert key = key ^ (key >> 14)
        tmp = key ^ key >>> 14;
        tmp = key ^ tmp >>> 14;
        tmp = key ^ tmp >>> 14;
        key = key ^ tmp >>> 14;

        // Invert key *= 265
        key *= 0xd38ff08b1c03dd39L;

        // Invert key = key ^ (key >> 24)
        tmp = key ^ key >>> 24;
        key = key ^ tmp >>> 24;

        // Invert key = (~key) + (key << 21)
        tmp = ~key;
        tmp = ~(key - (tmp << 21));
        tmp = ~(key - (tmp << 21));
        key = ~(key - (tmp << 21));

        return key;
    }

    public static long hash(long key) {
        key = (~key) + (key << 21); // key = (key << 21) - key - 1;
        key = key ^ (key >>> 24);
        key = (key + (key << 3)) + (key << 8); // key * 265
        key = key ^ (key >>> 14);
        key = (key + (key << 2)) + (key << 4); // key * 21
        key = key ^ (key >>> 28);
        key = key + (key << 31);
        return key;
    }

    public static String hashString(long key) {
        return Long.toUnsignedString(hash(key), 32);
    }

    public static String hashString(Number key) {
        return (key == null) ? null : hashString(key.longValue());
    }
}