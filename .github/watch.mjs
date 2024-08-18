import fs from 'node:fs'
import path from 'node:path'


const dst = process.argv[2] || ''

const RATE = 50

function callback(fp, eventType) {
    // gray: \x1b[30m
    console.info(`\x1b[33mFile changed: \x1b[0m\x1b[30m${path.resolve(fp)}\x1b[0m`)
    if (dst) {
        let exists = fs.existsSync(fp)
        if (!exists) {
            // remove
            fs.unlink(path.resolve(dst, fp), (err) => {
                if (err) return
            })
        }
        fs.copyFile(fp, path.resolve(dst, fp), (err) => {
            if (err) return
        })
    }
}

let timeout = null;
function watch(...paths) {
    paths = paths.flat()
    for (let pathname of paths) {
        let exists = fs.existsSync(pathname)
        if (!exists) return
        let type = fs.lstatSync(pathname).isDirectory() ? 'directory' : 'file'
        fs.watch(pathname, (eventType, filename) => {
            if (filename) {
                if (timeout) clearTimeout(timeout)
                timeout = setTimeout(() => {
                    let fp = type === "directory" ? path.join(pathname, filename) : pathname
                    callback(fp, eventType)
                }, RATE)
            }
        })
    }
}

watch('config')
watch(['site-config.yml', 'site-config.yaml', 'site-config.json'])