#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<cuda_runtime.h>
#include<device_launch_parameters.h>


__global__ void kernel(char* da, char* db, char* dlen) {
	int idx = threadIdx.x + blockDim.x * blockIdx.x;

	if (idx < *dlen) {
		int si = *dlen - idx - 1;
		db[si] = da[idx];
	}
}
int main() {
	int n;
	printf("Enter N: ");
	scanf("%d", &n);

	char* a, * b;
	char* da, * db, * dlen;
	int size = n * sizeof(char);
	a = (char*)malloc(size);
	b = (char*)malloc(size);
	memset(b, 0, size);

	printf("Enter string A: ");
	scanf("%s", a);
	int len = strlen(a);

	cudaMalloc((void**)&da, size);
	cudaMalloc((void**)&db, size);
	cudaMalloc((void**)&dlen, sizeof(int));

	cudaMemcpy(da, a, size, cudaMemcpyHostToDevice);
	cudaMemcpy(db, b, size, cudaMemcpyHostToDevice);
	cudaMemcpy(dlen, &len, sizeof(int), cudaMemcpyHostToDevice);

	kernel << <1, len >> > (da, db, dlen);

	cudaMemcpy(b, db, size, cudaMemcpyDeviceToHost);

	b[len] = '\0';
	printf("%s", b);

	return 0;
}