{
    "lookup-objects":[
        {
            "type":"answer-sequence",
            "name":"sf-hills",
            "content": {
                "options":[
                    {
                        "order":1,
                        "answer-text":"31",
                        "answer-id":"31hills",
                        "is-correct-answer":false
                    },
                    {
                        "order":2,
                        "answer-text":"43 (correct)",
                        "answer-id":"43hills",
                        "is-correct-answer":true
                    },
                    {
                        "order":3,
                        "answer-text":"61",
                        "answer-id":"61hills",
                        "is-correct-answer":false
                    }
                ]
            }
        },
        {
            "type":"answer-sequence",
            "name":"sf-bridges",
            "content": {
                "options":[
                    {
                        "order":1,
                        "answer-text":"Golden Gate Bridge (correct)",
                        "answer-id":"brooklynbridge",
                        "is-correct-answer":true
                    },
                    {
                        "order":2,
                        "answer-text":"Brooklyn Bridge",
                        "answer-id":"43hills",
                        "is-correct-answer":false
                    },
                    {
                        "order":3,
                        "answer-text":"London Bridge",
                        "answer-id":"londonbridge",
                        "is-correct-answer":false
                    }
                ]
            }
        },
        {
            "type":"answer-sequence",
            "name":"sf-size",
            "content": {
                "options":[
                    {
                        "order":1,
                        "answer-text":"7 square miles (correct)",
                        "answer-id":"7sqm",
                        "is-correct-answer":true
                    },
                    {
                        "order":2,
                        "answer-text":"14 square miles",
                        "answer-id":"14sqm",
                        "is-correct-answer":false
                    },
                    {
                        "order":3,
                        "answer-text":"21 square miles",
                        "answer-id":"21sqm",
                        "is-correct-answer":false
                    }
                ]
            }
        },
        {
            "type":"answer-sequence",
            "name":"sample-colors",
            "content": {
                "options":[
                    {
                        "order":1,
                        "answer-text":"Blue (correct)",
                        "answer-id":"blue",
                        "is-correct-answer":true
                    },
                    {
                        "order":2,
                        "answer-text":"Dog",
                        "answer-id":"dog",
                        "is-correct-answer":false
                    },
                    {
                        "order":3,
                        "answer-text":"Green (correct)",
                        "answer-id":"green",
                        "is-correct-answer":true
                    },
                    {
                        "order":4,
                        "answer-text":"Cat",
                        "answer-id":"cat",
                        "is-correct-answer":false
                    }
                ]
            }
        },
        {
            "type":"achievement-category",
            "name":"Sample",
            "content": {
            }
        }
    ],
    "learning-objects":[
        {
            "name" : "Resource Learning",
            "record-type" : "Resource",
            "duration" : 60,
            "description" : "Salesforce Developer force",
            "sync-progress" : false,
            "content" : {
                "name":"Resource Learning Sample",
                "resource-url":"https://developer.salesforce.com/?language=en",
                "training-params-url":true,
                "display-in-iframe":true,
                "description":null,
                "delegate-assignment-completion":false
            }
        },
        {
            "name" : "Resource Learning 2",
            "record-type" : "Resource",
            "duration" : 60,
            "description" : "Service cloud overview",
            "sync-progress" : false,
            "content" : {
                "name":"Resource Learning Sample 2",
                "resource-url":"https://www.youtube.com/embed/hwKFv9X1yhU",
                "training-params-url":true,
                "display-in-iframe":true,
                "description":null,
                "delegate-assignment-completion":false
            }
        },
        {
            "name" : "Task Learning",
            "record-type" : "Task",
            "duration" : 60,
            "description" : "Complete the Force.com Workbook",
            "sync-progress" : false,
            "content" : {
                "name":"Task Learning Sample",
                "resource-name":"Force.com workbook",
                "resource-url":"https://www.salesforce.com/us/developer/docs/workbook/index.htm",
                "training-params-url":true,
                "description":null
            }
        },
        {
            "name" : "Task Learning 2",
            "record-type" : "Task",
            "duration" : 60,
            "description" : "Complete the Service Cloud Workbook",
            "sync-progress" : false,
            "content" : {
                "name":"Task Learning Sample",
                "resource-name":"Service Cloud workbook",
                "resource-url":"https://www.salesforce.com/us/developer/docs/workbook_service_cloud/workbook_service_cloud.pdf",
                "training-params-url":true,
                "description":null
            }
        },
        {
            "name" : "Quiz Learning 1",
            "record-type" : "Quiz",
            "duration" : 60,
            "description" : "Sample Quiz",
            "sync-progress" : false,
            "content" : {
                "name":"Quiz Learning Sample",
                "passing-score":70.0,
                "max-attempts":20,
                "question-lines" : [
                    {
                        "name" : "Page 1",
                        "order" : 1,
                        "description" :"Page 1 Description",
                        "questions" :[
                            {
                                "order" : 1,
                                "description" : "How many hills make up the San Francisco landscape?",
                                "type" : "SelectOneQuestion",
                                "answer-sequence" : "sf-hills"
                            },
                            {
                                "order" : 2,
                                "description" : "Which of these famous bridges is located in San Francisco?",
                                "type" : "SelectOneQuestion",
                                "answer-sequence" : "sf-bridges"
                            },
                            {
                                "order" : 3,
                                "description" : "How large is San Francisco?",
                                "type" : "SelectOneQuestion",
                                "answer-sequence" : "sf-size"
                            }
                        ]
                    },
                    {
                        "name" : "Page 2",
                        "order" : 2,
                        "description" :"Page 2 Description",
                        "questions" :[
                            {
                                "order" : 1,
                                "description" : "Select the valid colors from the list:",
                                "type" : "SelectMultipleQuestion",
                                "answer-sequence" : "sample-colors"
                            },
                            {
                                "order" : 2,
                                "description" : "Are you happy to be here?",
                                "type" : "True/False",
                                "correct-boolean" : "true"
                            }
                        ]
                    }
                ]
            }
        },
        {
            "name" : "RichText Learning",
            "record-type" : "RichText",
            "description" : "Sample RichText",
            "sync-progress" : false,
            "duration" : 10,
            "content" : {
                "hide-topics" : false,
                "name" : "RichText Learning Sample",
                "contents" : [
                    {
                        "content" : "Lorem ipsum dolor sit amet, no reque appetere eum, copiosae inimicus vel ex. Qui ea meis sanctus. In quod doctus definitiones vis, eum habemus phaedrum at, usu te homero partem legendos. Ad adhuc summo persequeris ius, has ei legimus deserunt persecuti, ex probo legendos pro. Debet minimum ius cu, ei vix natum alterum saperet.<br><br>Sonet affert vituperatoribus ius ut, ut nostrud quaestio vix. No idque indoctum mea, quo ea posse aliquid invidunt. At mei simul accusam democritum, ne posse quidam eum. Admodum offendit phaedrum ius no, pri ea solum mollis appareat. Mucius option tincidunt has eu, vivendum abhorreant repudiandae no nam.<br><br>At feugiat qualisque instructior per, te mei tale labore, ea sed rebum ludus officiis. Clita alienum gloriatur eu pri. An errem deterruisset qui, has cu atomorum theophrastus. Recteque reprimique ne sit.<br><br>Mea te modus dolore sanctus, ei est autem tantas, eu delenit insolens philosophia duo. Fugit definitiones ne vel, cetero dolorem tibique vix ex. Mazim corrumpit efficiendi id has, eius munere nonumy ei mel, eos adhuc harum ex. Ne noster inermis has. Causae probatus et has.<br><br>Nemore delenit salutatus vel ut, vis omnis tation id. Dolore oportere iudicabit nec et. Graeci eligendi repudiare cum no, an melius signiferumque vel, ad mel tamquam rationibus. Vis clita graece evertitur ad, per at eirmod platonem, mutat deseruisse sea eu. Dicam nonumes vix no, in qui pertinax qualisque.",
                        "title" : "Section 1",
                        "order" : 1
                    },
                    {
                        "content" : "Lorem ipsum dolor sit amet, no reque appetere eum, copiosae inimicus vel ex. Qui ea meis sanctus. In quod doctus definitiones vis, eum habemus phaedrum at, usu te homero partem legendos. Ad adhuc summo persequeris ius, has ei legimus deserunt persecuti, ex probo legendos pro. Debet minimum ius cu, ei vix natum alterum saperet.<br><br>Sonet affert vituperatoribus ius ut, ut nostrud quaestio vix. No idque indoctum mea, quo ea posse aliquid invidunt. At mei simul accusam democritum, ne posse quidam eum. Admodum offendit phaedrum ius no, pri ea solum mollis appareat. Mucius option tincidunt has eu, vivendum abhorreant repudiandae no nam.<br><br>At feugiat qualisque instructior per, te mei tale labore, ea sed rebum ludus officiis. Clita alienum gloriatur eu pri. An errem deterruisset qui, has cu atomorum theophrastus. Recteque reprimique ne sit.<br><br>Mea te modus dolore sanctus, ei est autem tantas, eu delenit insolens philosophia duo. Fugit definitiones ne vel, cetero dolorem tibique vix ex. Mazim corrumpit efficiendi id has, eius munere nonumy ei mel, eos adhuc harum ex. Ne noster inermis has. Causae probatus et has.<br><br>Nemore delenit salutatus vel ut, vis omnis tation id. Dolore oportere iudicabit nec et. Graeci eligendi repudiare cum no, an melius signiferumque vel, ad mel tamquam rationibus. Vis clita graece evertitur ad, per at eirmod platonem, mutat deseruisse sea eu. Dicam nonumes vix no, in qui pertinax qualisque.",
                        "title" : "Section 2",
                        "order" : 2
                    }
                ]
            }
      }
    ],
    "achievement-objects":[
        {
            "name" : "Sample Achievement",
            "type" : "Achievements",
            "achievement-category" : "Sample",
            "acquired-image" : "<img alt=\"User-added image\" src=\"/resource/lmscore_uilib/img/sampleLogo1.png\"></img>",
            "eligible-image" : "<img alt=\"User-added image\" src=\"/resource/lmscore_uilib/img/sampleLogo2.png\"></img>"
        }
    ],
    "plan-objects":[
        {
            "name" : "Sample Learning Plan",
            "description" : "Sample Learning Plan description",
            "status" : "Active",
            "enforce-sequence" : false,
            "enable-self-registration" : false,
            "self-registration-access" : null,
            "sections" : [
                {
                    "name" : "Section 1",
                    "order" : 1,
                    "items" : [
                        {
                            "order" : 1,
                            "learning" : "RichText Learning"
                        },
                        {
                            "order" : 2,
                            "learning" : "Resource Learning"
                        },
                        {
                            "order" : 3,
                            "learning" : "Task Learning"
                        }
                    ]
                },
                {
                    "name" : "Section 2",
                    "order" : 2,
                    "items" : [
                        {
                            "order" : 1,
                            "learning" : "Resource Learning 2"
                        },
                        {
                            "order" : 2,
                            "learning" : "Task Learning 2"
                        }
                    ]
                },
                {
                    "name" : "Section 3",
                    "order" : 3,
                    "items" : [
                        {
                            "order" : 1,
                            "learning" : "Quiz Learning 1"
                        }
                    ]
                }
            ],
            "achievements" : [
                {
                    "achievement" : "Sample Achievement",
                    "main-achievement" : true,
                    "section" : null
                }
            ]
        }
    ]

}
