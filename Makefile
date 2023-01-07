docker-build-builder:
	docker build -t tmt-builder . -f docker/dockerfile-builder;

docker-build-lt:
	cd docker && docker build -t tmt-languagetool . -f dockerfile-languagetool;

docker-build-webapp:
	cp docker/dockerfile-webapp docker/dockerfile-webapp-local;
	sed -i "s+registry.softcatala.org/github/++g" docker/dockerfile-webapp-local;
	docker build --no-cache -t tmt-webapp . -f docker/dockerfile-webapp-local;

docker-build-webapp-test:
	docker build -t tmt-webapp-test . -f docker/dockerfile-webapp-test;

docker/.env:
	@echo "Created default docker/.env file. Setup the necessary environment variables for the docker containers"
	touch "docker/.env"

docker-builder-run: docker-build-builder docker-build-lt docker/.env
	./docker/stop-docker.sh
	docker-compose -f docker/local.yml run -d --use-aliases --name translation-memory-tools-lt tmt-languagetool;
	docker-compose -f docker/local.yml run -v $PWD$/tmt-files:/srv/tmt-files --use-aliases --name translation-memory-tools tmt-builder;
	docker cp translation-memory-tools:/srv/web-docker .;
	docker build -t translation-memory-tools-build-data:master . -f docker/dockerfile-data;
	./docker/stop-docker.sh;

docker-webapp-run: docker-build-webapp
	docker run -p 8080:8080 -i -t tmt-webapp;

docker-webapp-test-run: docker-build-webapp-test
	docker run -p 8080:8080 -i -t tmt-webapp-test;