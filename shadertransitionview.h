#ifndef SHADERTRANSITIONVIEW_H
#define SHADERTRANSITIONVIEW_H

#include <QQuickItem>
#include <QStack>
#include <QDebug>
#include <QQmlComponent>

class ShaderTransitionView : public QQuickItem
{
    Q_OBJECT
    Q_DISABLE_COPY(ShaderTransitionView)

    Q_PROPERTY(QString transition READ transition WRITE setTransition NOTIFY transitionChanged)



public:
    ShaderTransitionView(QQuickItem *parent = 0);
    ~ShaderTransitionView();


    QString transition() const { return m_transition; }

    Q_INVOKABLE void pushQQuickItem( QQmlComponent* item ) { m_insideStack.push(item); }
    Q_INVOKABLE QQmlComponent* popQQuickItem() {
        if( m_insideStack.length() > 0 ) {
            return m_insideStack.pop();
        } else {
            return NULL;
        }
    }
    Q_INVOKABLE int lengthQQuickStack() { return m_insideStack.length(); }
    Q_INVOKABLE QQmlComponent* topQQuickItem() {
        if( m_insideStack.length() > 0 ) {
            return m_insideStack.top();
        } else {
            return NULL;
        }
    }
    Q_INVOKABLE void clearQQuickStack() { m_insideStack.clear(); }
    Q_INVOKABLE QQmlComponent* getQQuickItem( int index ) {
        if( (index > 0) && (index < m_insideStack.length() ) ) {
            return m_insideStack.takeAt( index );
        } else {
            return NULL;
        }
    }

public slots:
    void setTransition(QString transition)
    {
        if (m_transition == transition)
            return;

        m_transition = transition;
        emit transitionChanged(transition);
    }

signals:
    void transitionChanged(QString transition);

private:
    QString m_transition;

    QStack<QQmlComponent*> m_insideStack;
};

#endif // SHADERTRANSITIONVIEW_H

