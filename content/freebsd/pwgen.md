---
title: "랜덤 패스워드 만들기" 
date: 2017-11-03T21:01:48+09:00
image: 
tags: []
draft: false
---
시스템 관리를 하다보면 랜덤 스트링/패스워드가 필요할 때가 있습니다. 랜덤 패스워드 만들어 쓰는 방법에 대해 간단히 이야기합니다.

<!--more-->

랜덤 패스워드를 얻는 방법은 여러가지가 있습니다. 인터넷에 랜덤패스워드를 만들어주는 웹사이트도 있고, LDAP 패키지를 설치하면 같이 설치되는 ldappasswd 유틸리티도 있습니다. 사용자 계정을 만들어주는 스크립트를 자세..히 보면 거기서도 랜덤 패스워드를 만들어주는 유틸의 흔적을 찾을 수 있습니다.

그런데 이런거 그냥 내가 만들어 쓰면 안될까요? 라고 생각한다면 그것도 아주 쉽습니다. 약간의 코드만 쓰면 비교적 손쉽게 랜덤패스워드를 얻을 수 있습니다.

```
#include<stdio.h>
#include<fcntl.h>
#include<stdlib.h>
#include<unistd.h>

const char base64[]=
	"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890+/";

int main(int argc, char *argv[]){
	int fp,i,j,k;
	const int n = 3;
	unsigned char *buf;
	ssize_t rc;

	j = k = 10;
	
	buf = malloc(sizeof(unsigned char*)*j);
	fp = open("/dev/random",O_RDONLY);

	for(i=0;i<n;i++){
		rc = read(fp,buf,k);
		buf+=rc;
		k-=rc;
		if(k==0) break;
	}
	close(fp);

	buf-=j;
	for(i=0;i<j;i++)
		printf("%c",base64[buf[i]%(sizeof(base64)-1)]);
	printf("\n");

	free(buf);
	return 0;
}
```

FreeBSD에서는 Makefile도 간단합니다. 위 소스파일이 main.c라고 한다면,

```
PROG=randompass
SRCS=main.c

.include<bsd.prog.mk>
```
세줄로 해결됩니다.
