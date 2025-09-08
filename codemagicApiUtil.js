import axios from "axios";

const workflowId = "flutter-workflow"
const workflowIdNoSign = "flutter-workflow-nosign"
const branch = "master"
const service = axios.create({
    // api请求域名，默认为 https://api.codemagic.io
    baseURL: 'https://api.codemagic.io',
    timeout: 30000,
    headers: {
        "Content-Type": "application/json",
        // 流水线账户密钥
        "x-auth-token": "wsN4tTRMFdaEKV0oDXsHEDQNPXzmXvfrL9GrRCWt0gY"
    }
})

/**获取此用户的所有应用流水线
 *
 * {
 *   "applications": [{
 *     "_id": "6172cc7d57278d06d4e915f1",
 *    "appName": "Foobar-App",
 *    "workflowIds": [
 *      "5d85f242e941e00019e81bd2"
 *    ],
 *    "workflows": {
 *      "5d85f242e941e00019e81bd2": {
 *        "name": "Android Workflow"
 *       }
 *    }
 *   }]
 * }
 *
 * */
const getApps = async () => {
    const res = await service.get('/apps')
    return res.data
}

/** 流水线构建
 *
 * {
 *     "buildId":"5fabc6414c483700143f4f92"
 * }
 *
 * @param data 构建参数 { "appId": '6172cc7d57278d06d4e915f1', "workflowId": "5d85f242e941e00019e81bd2", "branch": "master" }
 *
 * */
const runBuild = async (data) => {
    const res = await service.post('/builds', data)
    return res.data
}

/**  取消构建
 *
 * @param buildId 构建ID 通过 runBuild 获取
 *
 * */
const cancelBuild = async (buildId) => {
    const res = await service({
        url: `/builds/${buildId}/cancel`,
        method: 'get',
        params: {}
    })
    return res.data
}

/** 获取构建列表
 *
 * {
 *   "applications": [
 *     {
 *       "_id": "5d85eaa0e941e00019e81bc2",
 *       "appName": "counter_flutter",
 *       ...
 *     }
 *   ],
 *   "builds": [
 *     {
 *       "_id": "5ec8eea2261f342603f4d0bc",
 *       "appId": "5d85eaa0e941e00019e81bc2",
 *       "workflowId": "5d85f242e941e00019e81bd2",
 *       "branch": "develop",
 *       "tag": null,
 *       "status": "finished",
 *       "startedAt": "2020-09-08T07:18:02.203+0000",
 *       "finishedAt": "2020-09-08T07:20:13.040+0000",
 *       "artefacts": [
 *         {
 *           "md5": "81298e2f39a0e2d401b583f4f32d88d1",
 *           "name": "app-debug.apk",
 *           "packageName": "io.codemagic.counter-flutter",
 *           "size": 59325441,
 *           "type": "apk",
 *           "url": "https://api.codemagic.io/artifacts/2667d83f-a05b-44a5-8839-51fd4b05e7ce/d44b59f6-ebe9-4ca5-80ee-86ce372790ee/app-debug.apk",
 *           "versionName": "1.0.2"
 *         },
 *         {
 *           "md5": "d34bf9732ef125bd761d76b2cf3017bc",
 *           "name": "Runner.app",
 *           "size": 96849493,
 *           "type": "app",
 *           "url": "https://api.codemagic.io/artifacts/5020d900-14c2-4e96-9c95-93869e1e2d2f/0ec3367c-704e-4d36-895b-6b3944e43113/Runner.app"
 *         }
 *       ],
 *       ...
 *     },
 *     ...
 *   ]
 * }
 *
 * @param params 构建参数 { "appId": '6172cc7d57278d06d4e915f1', "workflowId": "5d85f242e941e00019e81bd2", "branch": "master" }
 *
 * */
const getBuilds = async (params) => {
    const res = await service({
        url: '/builds',
        method: 'get',
        params
    })
    return res.data
}

/** 获取构建状态
 *
 * {
 *   "application": {
 *     "_id": "5d85eaa0e941e00019e81bc2",
 *     "appName": "counter_flutter"
 *   },
 *   "build": {
 *     "_id": "5ec8eea2261f342603f4d0bc",
 *     "startedAt": "2020-05-23T09:36:39.028+0000",
 *     "status": "building", // 可选取值 building, canceled, finishing, finished, failed, fetching, preparing, publishing, queued, skipped, testing, timeout, warning
 *     "workflowId": "5d85f242e941e00019e81bd2"
 *   }
 * }
 *
 * */
const getBuildStatus = async (buildId) => {
    const res = await service({
        url: `/builds/${buildId}`,
        method: 'get',
        params: {}
    })
    return res.data
}

/** 创建公共下载 URL (如apk、ipa等)，要在构建承购后才能使用
 *
 * @param authenticatedDownloadURL 需身份验证的下载 URL，对应 getBuilds 中返回的 artefacts.url
 *
 */
const createPublicDownloadURL = (authenticatedDownloadURL) => {
    const thirtyDay = Date.now() + (30 * 24 * 60 * 60 * 1000)
    return service({
        // 完整的url示例：https://api.codemagic.io/artifacts/2667d83f-a05b-44a5-8839-51fd4b05e7ce/d44b59f6-ebe9-4ca5-80ee-86ce372790ee/app-debug.apk/public-url
        url: `${authenticatedDownloadURL}/public-url`,
        method: 'post',
        params: {
            // 下载链接过期时间：秒级时间戳，默认 30 天
            "expiresAt": Math.floor(thirtyDay / 1000),
        }
    })
}







let timer
const testGetBuildStatus = async (buildId, callback) => {
    timer && clearInterval(timer)
    // 创建一个定时器，每 5 秒执行一次，用于轮询构建状态
    timer = setInterval(async () => {
        const buildStatus = await getBuildStatus(buildId)
        console.log("3.getBuildStatus  =", buildStatus)
        if (buildStatus?.build?.status === "finished") {
            timer && clearInterval(timer)
            console.log("3-1.构建成功 产物artefacts=", buildStatus?.build?.artefacts)
            // 构建完成，回传artefacts打包后产物集合
            callback && callback(buildStatus?.build?.artefacts)
        } else if (buildStatus?.build?.status === "failed"
            || buildStatus?.build?.status === "canceled"
            || buildStatus?.build?.status === "timeout"
            || buildStatus?.build?.status === "skipped") {
            timer && clearInterval(timer)
        }
    }, 5000)
}
// test测试 打包构建下载链接 一条龙
export const testWorkflow = async () => {
    // 第一步：获取应用列表
    const apps = await getApps()
    console.log("1.getApps =", apps)

    // 第二步：运行构建
    const buildId = await runBuild({
        // 通过 getApps 可获取
        "appId": apps?.applications[0]?._id,
        "workflowId": workflowId,
        "branch": branch,
    })
    console.log("2.runBuild =", buildId)

    // 第三步：轮询获取构建状态
    await testGetBuildStatus(buildId?.buildId, async (artefacts) => {
        // 第四步：创建公共下载 URL
        for (let i = 0; i < artefacts?.length; i++) {
            const authenticatedDownloadURL = artefacts[i]?.url
            const publicDownloadURL = await createPublicDownloadURL(authenticatedDownloadURL)
            console.log("4.createPublicDownloadURL =>",
                "fileType=", artefacts[i]?.type,
                "authenticatedDownloadURL=", authenticatedDownloadURL,
                "publicDownloadURL=", publicDownloadURL)
        }
    })
}