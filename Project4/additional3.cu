#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<cuda_runtime.h>
#include<device_launch_parameters.h>


__global__ void kernel(char* da, char* db, int* dlen) {
	int idx = threadIdx.x + blockDim.x * blockIdx.x;

	if (idx < *dlen) {
		int si = 0;
		for (int i = 0; i < idx; i++) {
			//si += (*dlen) - (*dlen - idx);
			si += i + 1;
		}

		int total_chars = idx + 1;
		for (int i = 0; i < total_chars; i++)
			db[si++] = da[idx];
			//db[si + i] = da[idx];
	}
}
int main() {
	int n;
	printf("Enter N: ");
	scanf("%d", &n);

	char* a, * b;
	char* da, * db;
	int* dlen;
	int size = n * sizeof(char);
	a = (char*)malloc(size);

	printf("Enter string A: ");
	scanf("%s", a);
	int len = strlen(a);

	int blen = 0;
	for (int i = 0; i < len; i++)
		blen += i + 1;

	int bsize = blen * sizeof(char);
	b = (char*)malloc(bsize);
	memset(b, 0, bsize);

	cudaMalloc((void**)&da, size);
	cudaMalloc((void**)&db, bsize);
	cudaMalloc((void**)&dlen, sizeof(int));

	cudaMemcpy(da, a, size, cudaMemcpyHostToDevice);
	cudaMemcpy(db, b, bsize, cudaMemcpyHostToDevice);
	cudaMemcpy(dlen, &len, sizeof(int), cudaMemcpyHostToDevice);

	kernel << <1, len >> > (da, db, dlen);

	cudaMemcpy(b, db, bsize, cudaMemcpyDeviceToHost);

	b[blen] = '\0';
	printf("%s", b);

	return 0;
}