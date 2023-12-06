#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<cuda_runtime.h>
#include<device_launch_parameters.h>

/*
__global__ void kernel(char* da, char* db, int* dlen, int* N) {
	int idx = threadIdx.x + blockDim.x * blockIdx.x;

	if (idx < *dlen) {
		int si = idx;

		/*int total_chars = *N - 1;
		for (int i = 0; i < total_chars; i++) {
			si = si + (*dlen);
			db[si] = da[idx];
			//db[si + i] = da[idx];
		}

		for (int i = 1; i < *N; i++) {
			si += *dlen;
			db[si] = da[idx];
		}
	}

}*/

__global__ void kernel(char* da, char* db, int* dlen, int* N) {
	int idx = threadIdx.x + blockDim.x * blockIdx.x;
	//int si = 0;
	if (idx < *dlen) {
		for (int i = 0; i < *N; i++) {
			int si = idx + (*dlen)*i;
			db[si] = da[idx];
		}
	}
}
int main() {
	int n, N;
	printf("Enter string length: ");
	scanf("%d", &n);

	char* a, * b;
	char* da, * db;
	int* dlen, * dN;
	int size = n * sizeof(char);
	a = (char*)malloc(size);

	printf("Enter string A: ");
	scanf("%s", a);
	int len = strlen(a);

	printf("Enter N: ");
	scanf("%d", &N);

	int blen = N * len;

	int bsize = blen * sizeof(char);
	b = (char*)malloc(bsize);
	memset(b, 0, bsize);

	cudaMalloc((void**)&da, size);
	cudaMalloc((void**)&db, bsize);
	cudaMalloc((void**)&dlen, sizeof(int));
	cudaMalloc((void**)&dN, sizeof(int));

	cudaMemcpy(da, a, size, cudaMemcpyHostToDevice);
	cudaMemcpy(db, b, bsize, cudaMemcpyHostToDevice);
	cudaMemcpy(dlen, &len, sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(dN, &N, sizeof(int), cudaMemcpyHostToDevice);

	kernel << <1, len >> > (da, db, dlen, dN);

	cudaMemcpy(b, db, bsize, cudaMemcpyDeviceToHost);

	b[blen] = '\0';
	printf("%s", b);

	return 0;
}