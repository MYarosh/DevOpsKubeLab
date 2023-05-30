# DevOpsKubeLab
Задание
-------

1.  Создайте web-приложение, которое выводит содержимое из папки app
2.  Соберите его в виде Docker image
3.  Установите image в кластер Kubernetes
4.  Обеспечьте доступ к приложению извне кластера

### Пояснения

1.  В качестве web-сервера для простоты можно воспользоваться Python:
    "python -m http.server 8000".
    1.  Добавьте эту команду в инструкцию CMD в Dockerfile.
2.  Создать Dockerfile на основе "python:3.10-alpine", в котором.
    1.  Создать каталог "/app" и назначить его как WORKDIR.
    2.  Добавить в него файл, содержащий текст "Hello world".
    3.  Обеспечить запуск web-сервера от имени пользователя с "uid
        1001".
3.  Собрать Docker image с tag "1.0.0".
4.  Запустить Docker container и проверить, что web-приложение работает.
5.  Выложить image на Docker Hub.
6.  Создать Kubernetes Deployment manifest, запускающий container из
    созданного image.
    1.  Имя Deployment должно быть "web".
    2.  Количество запущенных реплик должно равняться двум.
    3.  Добавить использование Probes.
7.  Установить manifest в кластер Kubernetes.
8.  Обеспечить доступ к web-приложению внутри кластера и проверить его
    работу
    1.  Воспользоваться командой kubectl port-forward: "kubectl
        port-forward --address 0.0.0.0 deployment/web 8080:8000".
    2.  Перейти по адресу <http://127.0.0.1:8080/hello.html>.

### Результаты

1.  Выложить результаты работы в Github
2.  README.md с описанием выполненных шагов
3.  Dockerfile
4.  Kubernetes Deployment manifest в виде yaml
5.  Результат команды "kubectl describe deployment web"
6.  Прислать ссылку на Github repo или gist на e-mail
    Dmitriy.Zverev\@nexign.com. В теме письма указать свои фамилию и
    имя.

## Выполнение

1. Создание файлов и директорий

```bash
mkdir labs
cd labs

touch Dockerfile
touch deployments.yaml

mkdir app
echo "Hello World" > app/hello.html
```

2. Заполнение Dockerfile

```dockerfile
FROM python:3.10-alpine

ARG UID=1001

USER ${UID}

WORKDIR /app

COPY --chown=${UID} app/hello.html ./hello.html

EXPOSE 8000

CMD [ "python3", "-m", "http.server", "8000" ]
```

3. Создание образа и push его в хранилище

```bash
docker build -t docker.io/myarosh/lab:latest .
docker tag docker.io/myarosh/lab:latest docker.io/myarosh/lab:1.0.0
docker push docker.io/myarosh/lab:latest
docker push docker.io/myarosh/lab:1.0.0
```

4. Подготовка окружения kube

Для создания кластера используем minicube. Для проверки используем команду `kubectl cluster-info` 

```plain
kubectl cluster-info
Kubernetes control plane is running at https://192.168.49.2:8443
CoreDNS is running at https://192.168.49.2:8443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

5. Заполнение манифеста для deployments

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
        - name: web
          image: docker.io/myarosh/lab:1.0.0
          ports:
            - name: port1
              containerPort: 8000
          livenessProbe:
            httpGet:
              path: /hello.html
              port: port1
            initialDelaySeconds: 5
            periodSeconds: 5
```

6. Деплой приложения

```bash
kubectl apply -f ./deployments.yml
```

Для проверки запуска deployments выполним команду `kubectl describe deployment web`

```plain
user@VM:~/labs$ kubectl describe deployment web
Name:                   web
Namespace:              default
CreationTimestamp:      Sat, 27 May 2023 18:11:26 +0300
Labels:                 <none>
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=web
Replicas:               2 desired | 2 updated | 2 total | 2 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=web
  Containers:
   web:
    Image:        docker.io/myarosh/lab:latest
    Port:         8000/TCP
    Host Port:    0/TCP
    Liveness:     http-get http://:port1/hello.html delay=5s timeout=1s period=5s #success=1 #failure=3
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   web-764678755d (2/2 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  29s   deployment-controller  Scaled up replica set web-764678755d to 2
```

7. Проверим доступность nginx. Для этого выполним команду
`kubectl port-forward --address 0.0.0.0 deployment/web 8080:8000`.
Для проверки сделаем web запрос на <http://127.0.0.1:8080/hello.html>.
![изображение](https://github.com/MYarosh/DevOpsKubeLab/assets/57475688/7279838b-a96d-4edf-b7c1-b51f8c43b045)
