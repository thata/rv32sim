int fibonacci(int n) {
  if (n == 1) {
    return 1;
  } else if (n == 2) {
    return 1;
  } else {
    return fibonacci(n - 2) + fibonacci(n - 1);
  }
}

int main() {
  return fibonacci(10);
}
