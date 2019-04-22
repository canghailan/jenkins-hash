# Wang/Jenkins Hash算法

[Wang/Jenkins Hash算法](http://d0evi1.com/wang-jenkins-hash/)
[Inverse of a hash function](https://naml.us/post/inverse-of-a-hash-function/)


```c
uint64_t hash(uint64_t key) {
  key = (~key) + (key << 21); // key = (key << 21) - key - 1;
  key = key ^ (key >> 24);
  key = (key + (key << 3)) + (key << 8); // key * 265
  key = key ^ (key >> 14);
  key = (key + (key << 2)) + (key << 4); // key * 21
  key = key ^ (key >> 28);
  key = key + (key << 31);
  return key;
}
```


```c
uint64_t inverse_hash(uint64_t key) {
  uint64_t tmp;

  // Invert key = key + (key << 31)
  tmp = key-(key<<31);
  key = key-(tmp<<31);

  // Invert key = key ^ (key >> 28)
  tmp = key^key>>28;
  key = key^tmp>>28;

  // Invert key *= 21
  key *= 14933078535860113213u;

  // Invert key = key ^ (key >> 14)
  tmp = key^key>>14;
  tmp = key^tmp>>14;
  tmp = key^tmp>>14;
  key = key^tmp>>14;

  // Invert key *= 265
  key *= 15244667743933553977u;

  // Invert key = key ^ (key >> 24)
  tmp = key^key>>24;
  key = key^tmp>>24;

  // Invert key = (~key) + (key << 21)
  tmp = ~key;
  tmp = ~(key-(tmp<<21));
  tmp = ~(key-(tmp<<21));
  key = ~(key-(tmp<<21));

  return key;
}
```