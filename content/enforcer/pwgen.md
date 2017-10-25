---
title: "Generating Random Password"
date: 2017-10-25
description: "How to generate random password easily" 
tags: ["c","password"]
draft: false
---
거의 모-든 보안조치의 시작과 끝은 **비밀번호**일 경우가 많습니다. 최근에는 다중 인증 방식도 많이 도입되고 있지만 아직도 '잘만들고 잘유지하는' 비밀번호 하나에 거의 모든 보안을 의존하는 경우가 많습니다.

그러나 '잘만든' 비밀번호를 찾기란 때때로 아주 어렵습니다. 그래서 스스로 비밀번호를 만드는 것 보다 누군가가 잘 만들어준 비밀번호를 외우는 것이 오히려 편하고 안전할 때가 많습니다. 일정한 조건에 맞춰 비밀번호를 생성해주는 서비스를 하는 웹페이지가 많은 이유도 그와 같은 이유 때문입니다.

잘 만든 비밀번호를 찾기 위해서 반드시 비밀번호를 생성 해주는 웹 서비스나 바이너리 유틸을 사용할 필요는 없습니다. 약간의 프로그래밍 능력만 있다면 손쉽게 강력한 비밀번호를 생성 해 낼 수 있기 때문입니다.

아래 예시 소스코드를 참조한다면 개발중인 프로그램 내에서, 또는 독립적인 유틸을 설치하지 않고도 좋은 비밀번호를 생성 해 내는데 문제가 없으리라 생각합니다.

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
