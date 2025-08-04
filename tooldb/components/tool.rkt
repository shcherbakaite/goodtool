#lang racket/base

(require component
         db
         deta
         gregor
         koyo/database
         koyo/hasher
         koyo/profiler
         koyo/random
         racket/contract/base
         racket/string
         threading)

;; tool ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(provide
 (schema-out material)
 (schema-out tool)
 (schema-out application)
 (schema-out application_tool)
 make-tool-manager
 tool-manager?
 tool-manager-db
 tools-list-all
 get-tool-by-id
 get-tool-applications
 query-application-tools
 materials-list-all
 get-material-by-id
 get-material-applications
 get-application-by-id
 get-application-tools
 get-application-materials
 tools-search
 get-application-tool-by-id 
)


(define-schema material
  ([id id/f #:primary-key #:auto-increment]
   [partno string/f #:contract non-empty-string? #:wrapper string-upcase]
   [description string/f #:contract non-empty-string? #:wrapper string-upcase]
   [manufactorer string/f #:wrapper string-upcase]
   [mpn string/f #:wrapper string-upcase]))

(define-schema tool
  ([id id/f #:primary-key #:auto-increment]
   [partno string/f #:contract non-empty-string? #:wrapper string-upcase]
   [description string/f #:contract non-empty-string? #:wrapper string-upcase]
   [manufactorer string/f #:wrapper string-upcase]
   [mpn string/f #:wrapper string-upcase]
   [image binary/f #:nullable #:contract (or/c bytes? #f)]
    ))

(define-schema application
  ([id id/f #:primary-key #:auto-increment]
   [description string/f #:wrapper string-upcase]
    )
  )

(define-schema application_tool
  ([id id/f #:primary-key #:auto-increment]
   [applicationid id/f ]
   [toolid id/f ]))

(define-schema application_material
  ([id id/f #:primary-key #:auto-increment]
   [applicationid id/f ]
   [materialid id/f ]))

(struct tool-manager (db)
  #:transparent)

(define (make-tool-manager db)
  (tool-manager db))

; (define (tools-list-all tm)
;   (with-database-connection [conn (tool-manager-db tm)]
;     (~> (from tool #:as t)
;         )
;         (query-entities conn)))


(define (get-tool-by-id tm id)
  (with-database-connection [conn (tool-manager-db tm)]
    (lookup
     conn
     (~> 
       (from tool #:as t)
       (where (= t.id ,id)) 
       ))))

(define (get-material-by-id tm id)
  (with-database-connection [conn (tool-manager-db tm)]
    (lookup
     conn
     (~> 
       (from material #:as m)
       (where (= m.id ,id)) 
       ))))

(define (get-application-by-id tm id)
  (with-database-connection [conn (tool-manager-db tm)]
    (lookup
     conn
     (~> 
       (from application #:as a)
       (where (= a.id ,id)) 
       ))))

(define (get-tool-applications tm id)
  (with-database-connection [conn (tool-manager-db tm)]
  (query-entities
   conn
   (~> 
     (from application #:as a)
     (join application_tool #:as at #:on (= a.id at.applicationid))
     (where (= at.toolid ,id))
     ; hide duplicated, in case tool is used multiple times in application
     (group-by a.id)
     ))))

(define (get-application-tool-by-id tm id)
  (with-database-connection [conn (tool-manager-db tm)]
    (lookup
     conn
     (~> 
       (from application_tool #:as at)
       (where (= at.id ,id)) 
       ))))

(define (get-material-applications tm id)
  (with-database-connection [conn (tool-manager-db tm)]
  (query-entities
   conn
   (~> 
     (from application #:as a)
     (join application_material #:as at #:on (= a.id at.applicationid))
     (where (= at.materialid ,id))
     ; hide duplicated, in case material is used multiple times in application
     (group-by a.id) 
     ))))

(define (tools-list-all tm)
  (with-database-connection [conn (tool-manager-db tm)]
    (query-entities
     conn
     (from tool #:as t))))

(define (materials-list-all tm)
  (with-database-connection [conn (tool-manager-db tm)]
    (query-entities
     conn
     (from material #:as t))))

(define (get-application-tools tm id)
  (with-database-connection [conn (tool-manager-db tm)]
  (query-entities
   conn
   (~> 
     (from tool #:as t)
     (join application_tool #:as at #:on (= t.id at.toolid))
     (where (= at.applicationid ,id))
     (order-by ([at.id])) 
     ))))

(define (query-application-tools tm id)
  (with-database-connection [conn (tool-manager-db tm)]
  (query
   conn
   (~> 
     (from tool #:as t)
     (join application_tool #:as at #:on (= t.id at.toolid))
     (select t.id t.description t.mpn t.partno (as at.id toolentryid) at.applicationid )
     (where (= at.applicationid ,id))
     (order-by ([at.id])) 
     ))))

(define (get-application-materials tm id)
  (with-database-connection [conn (tool-manager-db tm)]
  (query-entities
   conn
   (~> 
     (from material #:as m)
     (join application_material #:as am #:on (= m.id am.materialid))
     (where (= am.applicationid ,id))
     (order-by ([am.id]))  
     ))))

(define (build-like-format-string query-str)
  (define like-str (string-append "%" (string-join (filter non-empty-string? (string-split query-str " ")) "%") "%"))
  ;(displayln like-str)
  like-str
  )


(define (tools-search tm query-str)
  (define keywords (string-split query-str))
  ;(displayln (format "~s" keywords))
  (with-database-connection [conn (tool-manager-db tm)]
    (query-entities
       conn
       (~> 
        (from tool #:as t)
        (where (and (ilike (string-concat t.partno " - " t.description) ,(build-like-format-string query-str))))))))


  ; (define r (query
  ;         conn "SELECT t.id, t.partno, t.description, t.manufactorer, t.mpn FROM tools AS t WHERE t.description LIKE '%SPA%' " ))

  ;       (displayln (format "~s" r))

  ;       r


  ;       ))

; (define (tools-search tm query-str)
;   (define keywords (string-split query-str))
;   (displayln (format "~s" keywords))
  
;   (define like-caluses
;     (for/list ([k keywords])
;       `(like (string-concat t.description)
;              ,(string-append "%" k "%"))))

;   ;(displayln (string-append "term:" term))
;   (with-database-connection [conn (tool-manager-db tm)]
;     (query-entities
;      conn
;       (~>
;         (from tool #:as t)
;         (where (or . ,like-caluses) )) )))


(define (tools-search2  query-str)
  (define keywords (string-split query-str))
  ;(displayln (format "~s" keywords))
  
  (define like-clauses
    (for/list ([k keywords])
      `(like (string-concat t.partno " " t.description)
             ,(string-append "%" k "%"))))

  ;(displayln (string-append "term:" term))

      (~>
        (from tool #:as t)
        (where (or . ,like-clauses) )) )

; (~>
;         (from tool #:as t)
;         (where (like t.partno "%9%" )))


     ;(~> (select (from "tools" #:as t) t.id) (where (= id ,term))))))



  ; (displayln (string-append "term:" term))
  ; (with-database-connection [conn (tool-manager-db tm)]
  ;   (query-entities
  ;    conn
  ;     (~>
  ;       (from tool #:as t)
  ;       (where (like (string-concat t.partno " " t.description) (string-concat "%" ,term "%") ))) )))


  (define (tools-search3  query-str)
    (define keywords (string-split query-str))
    ;(displayln (format "~s" keywords))
    (define frag `(like (string-concat t.partno " " t.description) (string-concat "%" ,query-str "%") ))

    (~>
        (from tool #:as t)
        (where  ,frag)) )